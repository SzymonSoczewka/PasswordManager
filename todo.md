1. We assume Secret Key stored on the machine has been generated while user signed up
2. We use secret key along with user password to encrypt site-password to the db and to decrypt site-password from the db
3. AES secret key we derive from system Secret key combined with user password hashed with MD5 Hash