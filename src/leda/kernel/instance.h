/*
===============================================================================

Copyright (C) 2012 Tiago Salmito, Noemi Rodriguez, Ana Lucia de Moura

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

===============================================================================
*/
#ifndef _INSTANCE_H_
#define _INSTANCE_H_

#include "extra/threading.h"
#include "graph.h"

/* lua state structure */
typedef struct instance_data {
   lua_State * L;
   stage_id stage;
   //true if the stage is serial (i.e. only one instance is allowed)
   bool_t serial; 
   size_t args;
} * instance;

void instance_init(size_t limit);
instance instance_aquire(stage_id s);
void instance_release(instance i);
void instance_end(); //warning: thread unsafe
void instance_try_push_pending_queue(stage_id serial_stage, instance i);

#endif //_INSTANCE_H_
