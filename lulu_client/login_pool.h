#ifndef _LOGIN_POOL_H_
#define _LOGIN_POOL_H_

#include "im_login_service.h"

int login_pool_Init();
TEcLogin* login_pool_New();
int login_pool_Del(TEcLogin *_ptEcLogin);

#endif
