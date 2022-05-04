1. We assume Secret Key stored on the machine has been generated while user signed up
2. We use secret key along with user password to encrypt site-password to the db and to decrypt site-password from the db
3. AES secret key we derive from system Secret key combined with user password hashed with MD5 Hash


TODO:

Change Index view so that password is not shown on the table
Change Show view so that user password is enforced before you enter and see password
