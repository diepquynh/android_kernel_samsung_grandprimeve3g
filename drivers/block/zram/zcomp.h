/*
 * Copyright (C) 2014 Sergey Senozhatsky.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version
 * 2 of the License, or (at your option) any later version.
 */

#ifndef _ZCOMP_H_
#define _ZCOMP_H_

#include <linux/mutex.h>

struct zcomp_strm {
	/* compression/decompression buffer */
	void *buffer;
	struct crypto_comp *tfm;
	/* used in multi stream backend, protected by backend strm_lock */
	struct list_head list;
};

/* static compression backend */
struct zcomp_backend {
	int (*compress)(const unsigned char *src, unsigned char *dst,
			size_t *dst_len, void *private);

	int (*decompress)(const unsigned char *src, size_t src_len,
			unsigned char *dst);

	void *(*create)(void);
	void (*destroy)(void *private);

	const char *name;
};

/* dynamic per-device compression frontend */
struct zcomp {
	void *stream;
	struct zcomp_backend *backend;

	struct zcomp_strm *(*strm_find)(struct zcomp *comp);
	void (*strm_release)(struct zcomp *comp, struct zcomp_strm *zstrm);
	bool (*set_max_streams)(struct zcomp *comp, int num_strm);
	void (*destroy)(struct zcomp *comp);
	const char *name;
};

ssize_t zcomp_available_show(const char *comp, char *buf);

struct zcomp *zcomp_create(const char *comp, int max_strm);
void zcomp_destroy(struct zcomp *comp);

struct zcomp_strm *zcomp_strm_find(struct zcomp *comp);
void zcomp_strm_release(struct zcomp *comp, struct zcomp_strm *zstrm);

int zcomp_compress(struct zcomp_strm *zstrm,
		const void *src, unsigned int *dst_len);

int zcomp_decompress(struct zcomp_strm *zstrm,
		const void *src, unsigned int src_len, void *dst);

bool zcomp_set_max_streams(struct zcomp *comp, int num_strm);
#endif /* _ZCOMP_H_ */
