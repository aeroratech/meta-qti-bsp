/*
* Copyright (c) 2022 Qualcomm Innovation Center, Inc. All rights reserved.
* SPDX-License-Identifier: BSD-3-Clause-Clear
*/

#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <execinfo.h>
#include <semaphore.h>

extern "C" 
 {
static void * (*myfn_calloc)(size_t nmemb, size_t size) =NULL;
static void * (*myfn_malloc)(size_t size)=NULL;
static void   (*myfn_free)(void *ptr)=NULL;
static void * (*myfn_realloc)(void *ptr, size_t size)=NULL;
static void * (*myfn_memalign)(size_t blocksize, size_t bytes)=NULL;
static int malloc_hook_active = 0;
void* malloc_hook(size_t size,void*);
pthread_mutex_t lock;
static __thread int hook_active=1;
sem_t mutex;

enum fn_type{
  PRELOAD_MALLOC=0,
  PRELOAD_CALLOC,
  PRELOAD_REALLOC,
  PRELOAD_MEMALIGN,
  PRELOAD_FREE,
  PRELOAD_UNKNOWN
};

static void init()
{
    if(malloc_hook_active == 0) {
        if( sem_init(&mutex, 0, 1)) {
            fprintf(stderr, " mutex init has failed\n");
            exit(1);
        }
        myfn_malloc     = (void* (*)(size_t))dlsym(RTLD_NEXT, "malloc");
        myfn_free       = (void (*)(void*))dlsym(RTLD_NEXT, "free");
        myfn_calloc     = (void* (*)(size_t,size_t))dlsym(RTLD_NEXT, "calloc");
        myfn_realloc    = (void* (*)(void*, size_t))dlsym(RTLD_NEXT, "realloc");
        myfn_memalign   = (void* (*)(size_t,size_t))dlsym(RTLD_NEXT, "memalign");
        if (!myfn_malloc || !myfn_free || !myfn_calloc || !myfn_realloc || !myfn_memalign)
        {
            //fprintf(stderr, "#Error in `dlsym`: %s\n", dlerror());
        }
        malloc_hook_active = 1;
    }
}

void do_function_trace(int size, void *ptr, void* optr,enum fn_type type) {
  int n_func_ptrs = 0;
  void *bt_buffer[5];
  int j=0;
  hook_active =0;
  n_func_ptrs = backtrace(bt_buffer, 5);
  hook_active =1;

  sem_wait (&mutex);
  /* need mutex here, otherwise prints will not be aligned
  */
  if(type == PRELOAD_FREE)
     fprintf(stderr, "free(%p)      =    %p\n", ptr,ptr);
  else if(type == PRELOAD_MALLOC)
    fprintf(stderr, "malloc(%ld)    =    %p\n", size,ptr);
  else if(type == PRELOAD_REALLOC)
    fprintf(stderr, "realloc(%ld)   =    %p  %p\n", size,ptr,optr);
  else if(type == PRELOAD_CALLOC)
    fprintf(stderr, "calloc(%ld)    =    %p\n", size,ptr);
  else if(type == PRELOAD_MEMALIGN)
    fprintf(stderr, "memalign(%ld)    =    %p\n", size,ptr);

    for (j = 0; j < n_func_ptrs; j++)
        fprintf(stderr, "   > [%p]\n", bt_buffer[j]);
    sem_post(&mutex);
}

void* operator new (size_t size) {
  void* p = malloc(size);
  return p;
}

void operator delete (void* p) {
  free(p);
}

/*  getting complete stack trace but will
*   break in multi thread scenario because of hook_activ
*   thats the reason we made hook_active a thread variavle
*/
void* malloc (size_t size)
{
  void *ptr;
  if(myfn_malloc == NULL)
  {
    init();
    hook_active=1;
  }
  if(hook_active) {
    char *env_str =  getenv("MALLOCBT");
    ptr = myfn_malloc(size);
    if(env_str &&  env_str[0] == 'Y'){
        do_function_trace(size,ptr,NULL,PRELOAD_MALLOC);
    }
  }
  else{
    ptr = myfn_malloc(size);
  }
   return ptr;
 }

#define CALLOC_BUF (4096*2)
unsigned char Cbuffer[CALLOC_BUF]="";
void free (void *ptr)
{
  if (ptr == Cbuffer)
        return;
   if(myfn_malloc == NULL)
   {
      return;
   }
  char *env_str =  getenv("MALLOCBT");
  myfn_free(ptr);
  if(env_str &&  env_str[0] == 'Y'){
       if(env_str &&  env_str[0] == 'Y'){
        do_function_trace(0,ptr,NULL,PRELOAD_FREE);
    }
  }
}
void *realloc(void *ptr, size_t size)
{
    if(myfn_malloc == NULL)
    {
       init();
    }
    char buffer[50];  
    void *nptr = myfn_realloc(ptr,size);
    char *env_str =  getenv("MALLOCBT");
    if(env_str &&  env_str[0] == 'Y'){ 
          do_function_trace(size,nptr,ptr,PRELOAD_REALLOC);
    }
    return nptr;
}
void *calloc(size_t nmemb, size_t size)
{
   void *ptr;
   if(myfn_calloc == NULL)
   {
     if(size < CALLOC_BUF)
        return Cbuffer;
    else
        return NULL;
   }
   if(hook_active)
   {
    ptr = myfn_calloc(nmemb,size);
    char *env_str =  getenv("MALLOCBT");
    if(env_str &&  env_str[0] == 'Y'){ 
          do_function_trace((nmemb*size),ptr,NULL,PRELOAD_CALLOC);
    }
   }
   else{
       ptr = myfn_calloc(nmemb,size);
   }
   return ptr;
}

void *memalign(size_t blocksize, size_t bytes)
{
   void *ptr;
   if(myfn_memalign == NULL)
   {
    init();
	hook_active=1;
   }
  if(hook_active) {
    char *env_str =  getenv("MALLOCBT");
    ptr = myfn_memalign(blocksize, bytes);
    if(env_str &&  env_str[0] == 'Y'){
        do_function_trace(blocksize,ptr,NULL,PRELOAD_MEMALIGN);
    }
  }
  else{
    ptr = myfn_memalign(blocksize, bytes);
  }
   return ptr;
 }
 }
