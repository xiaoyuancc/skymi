/* Copyright (c) 2016, The Linux Foundation. All rights reserved.
 * Copyright (C) 2017 XiaoMi, Inc.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 and
 * only version 2 as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 */

#ifndef _LINUX_FS_ICE_H
#define _LINUX_FS_ICE_H

#include <linux/fs.h>
#include <linux/types.h>

#define  FS_AES_256_XTS_KEY_SIZE  64

#ifdef CONFIG_FS_ICE_ENCRYPTION

bool fscrypt_encrypted_inode(struct inode *inode);

int fscrypt_using_hardware_encryption(struct inode *inode);


static inline int fscrypt_should_be_processed_by_ice(const struct inode *inode)
{
	if (!fscrypt_encrypted_inode((struct inode *)inode))
		return 0;

	return fscrypt_using_hardware_encryption((struct inode *)inode);
}

static inline int fscrypt_is_ice_enabled(void)
{
	return 1;
}

int fscrypt_is_aes_xts_cipher(const struct inode *inode);

char *fscrypt_get_ice_encryption_key(const struct inode *inode);
char *fscrypt_get_ice_encryption_salt(const struct inode *inode);

int fscrypt_is_ice_encryption_info_equal(const struct inode *inode1,
										 const struct inode *inode2);

static inline size_t fscrypt_get_ice_encryption_key_size(
	const struct inode *inode)
{
	return FS_AES_256_XTS_KEY_SIZE / 2;
}

static inline size_t fscrypt_get_ice_encryption_salt_size(
	const struct inode *inode)
{
	return FS_AES_256_XTS_KEY_SIZE / 2;
}

#else

static inline int fscrypt_using_hardware_encryption(struct inode *inode) { return 0; }

static inline int fscrypt_should_be_processed_by_ice(const struct inode *inode)
{
	return 0;
}
static inline int fscrypt_is_ice_enabled(void)
{
	return 0;
}

static inline char *fscrypt_get_ice_encryption_key(const struct inode *inode)
{
	return NULL;
}

static inline char *fscrypt_get_ice_encryption_salt(const struct inode *inode)
{
	return NULL;
}

static inline size_t fscrypt_get_ice_encryption_key_size(
	const struct inode *inode)
{
	return 0;
}

static inline size_t fscrypt_get_ice_encryption_salt_size(
	const struct inode *inode)
{
	return 0;
}

static inline int fscrypt_is_xts_cipher(const struct inode *inode)
{
	return 0;
}

static inline int fscrypt_is_ice_encryption_info_equal(
	const struct inode *inode1,
	const struct inode *inode2)
{
	return 0;
}

static inline int fscrypt_is_aes_xts_cipher(const struct inode *inode)
{
	return 0;
}

#endif

#endif /* _LINUX_FS_ICE_H */
