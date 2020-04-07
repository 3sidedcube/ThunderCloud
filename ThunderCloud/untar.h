//
//  untar.h
//  Storm
//
//  Created by Tom Bell on 14/02/2013.
//  Copyright (c) 2013 3SIDEDCUBE. All rights reserved.
//

#ifndef Storm_untar_h
#define Storm_untar_h

typedef struct inflatedData
{
    void *data;
    size_t length;
} inflatedData;

void untar(FILE *a, const char *path);

#endif
