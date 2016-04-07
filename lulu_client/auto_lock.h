#ifndef __AUTO_LOCK_H__
#define __AUTO_LOCK_H__

#include <pthread.h>
#include <semaphore.h>
#include <sys/time.h>
#include <errno.h>

#define UserSpinLock 0

namespace MoMo
{
#if UserSpinLock
class SpinLock;
#endif

class Mutex;        /* 互斥量 */
class AutoMLock;    /* 互斥量封装自动锁 */

class RWLock;       /* 读写锁 */
class AutoRdLock;   /* 读写锁封装自动读锁 */
class AutoWrLock;   /* 读写锁封装自动写锁 */

class Semaphore;    /* 信号量 */

#if UserSpinLock
/**
 * @brief 自旋锁 
 */
class SpinLock
{
private:
	pthread_spinlock_t _lock;
public:
	inline SpinLock() 
	{
		pthread_spin_init(&_lock, PTHREAD_PROCESS_PRIVATE);
	}
	inline ~SpinLock() 
	{
		pthread_spin_destroy(&_lock);
	}
	inline int Lock() 
	{
		return pthread_spin_lock(&_lock);
	}
	inline int Unlock() 
	{
		return pthread_spin_unlock(&_lock);
	}
	inline int TryLock() 
	{
		return pthread_spin_trylock(&_lock);
	}
};
#endif
/**
 * @brief 互斥锁
 */
class Mutex
{
private:
	pthread_mutex_t _lock;
public:
	inline Mutex() 
	{ 
		pthread_mutex_init(&_lock, NULL); 
	}
	inline ~Mutex() 
	{ 
		pthread_mutex_destroy(&_lock); 
	}            
	inline int Lock() 
	{ 
		return pthread_mutex_lock(&_lock); 
	}
	inline int Unlock() 
	{ 
		return pthread_mutex_unlock(&_lock); 
	}
	pthread_mutex_t* GetMutex() { return &_lock;}
};

class Condition
{
public:
	explicit Condition(Mutex& mutex) : mutex_(mutex)
	{
		pthread_cond_init(&pcond_, NULL);
	}

	~Condition()
	{
		pthread_cond_destroy(&pcond_);
	}

	void wait() { pthread_cond_wait(&pcond_, mutex_.GetMutex());}

	// returns true if time out, false otherwise.
	bool waitForSeconds(int seconds)
	{
		struct timespec abstime;
		// FIXME: use CLOCK_MONOTONIC or CLOCK_MONOTONIC_RAW to prevent time rewind.
#ifdef CLOCK_REALTIME
		clock_gettime(CLOCK_REALTIME, &abstime);
		abstime.tv_sec += seconds;
#else
		struct timeval dwNow;
		gettimeofday(&dwNow, NULL); 
		abstime.tv_sec += dwNow.tv_sec + seconds;
		abstime.tv_nsec += dwNow.tv_usec * 1000;
#endif

		return ETIMEDOUT == pthread_cond_timedwait(&pcond_, mutex_.GetMutex(), &abstime);
	}

	void notify() { pthread_cond_signal(&pcond_); }
	void notifyAll() { pthread_cond_broadcast(&pcond_);}

private:
	Mutex& mutex_;
	pthread_cond_t pcond_;
};

/**
 * @brief 读写锁
 */
class RWLock
{
    private:
        pthread_rwlock_t _lock;
    public:
        inline RWLock() {
            pthread_rwlock_init(&_lock, NULL);
        }
        inline ~RWLock() {
            pthread_rwlock_destroy(&_lock);
        }
    public:
        inline int RdLock() {
            return pthread_rwlock_rdlock(&_lock);
        }
        inline int WrLock() {
            return pthread_rwlock_wrlock(&_lock);
        }
        inline int Unlock() {
            return pthread_rwlock_unlock(&_lock);
        }
};

/**
 * @brief 信号量
 */
class Semaphore
{
    private:
        sem_t _sem;
    public:
        inline Semaphore() {
            sem_init(&_sem, 0, 0);
        }
        inline ~Semaphore() {
            sem_destroy(&_sem);
        }
    public:
        inline int Wait() {
            return sem_wait(&_sem);
        }
//mac没有这个函数 sem_timedwait
#if 0
        inline int TimedWait(int timeout_ms) {
            struct timeval tv;
            struct timespec ts;

            gettimeofday(&tv, NULL);
            ts.tv_sec  = tv.tv_sec;
            ts.tv_nsec = tv.tv_usec * 1000 + timeout_ms * 1000 * 1000;

            ts.tv_sec += ts.tv_nsec / (1000 * 1000 * 1000);
            ts.tv_nsec %= 1000 * 1000 *1000;

            return sem_timedwait(&_sem, &ts);
        }
#endif
        inline int Post() {
            return sem_post(&_sem);
        }
};
#if UserSpinLock
/**
 * @brief 自动自旋锁 
 */
class AutoSLock
{
    private:
        SpinLock &_lock;
    public:
        inline AutoSLock(SpinLock &l):
            _lock(l) {
            _lock.Lock();
        }
        inline ~AutoSLock() {
            _lock.Unlock();
        }
};
#endif
/**
 * @brief 自动互斥锁
 */
class AutoMLock
{
    private:
        Mutex &_lock;
    public:
        inline AutoMLock(Mutex &l): _lock(l) 
		{   
            _lock.Lock(); 
        }
        inline ~AutoMLock() { 
            _lock.Unlock(); 
        }
};

/**
 * @brief 自动读锁
 */
class AutoRdLock
{
    private:
        RWLock &_lock;
    public:
        inline AutoRdLock(RWLock &l): 
            _lock(l) {   
            _lock.RdLock(); 
        }
        inline ~AutoRdLock() { 
            _lock.Unlock(); 
        }
};

/**
 * @brief 自动写锁
 */
class AutoWrLock
{
    private:
        RWLock &_lock;
    public:
        inline AutoWrLock(RWLock &l): 
            _lock(l) {   
            _lock.WrLock(); 
        }
        inline ~AutoWrLock() { 
            _lock.Unlock(); 
        }
};

}

#endif
