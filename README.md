# fr_utilities
This repo provides some Freedom Robotics API utilities written in bash intended to be used in Dockerfile for Device connection

# FreedomRobotics API overview
## Login
All actions require a valid token and secret (denoted as `mc_token` and `mc_secret`). These two strings refers to a single account and are valid for **two weeks**, unless a logout is performed.

To get `mc_token` and `mc_secret` email and password of the Freedom account must be provided.

The login is performed by file `FR_user_login.sh`. Credentials could be stored in a file called `fr_credentials.env` (preferred) or provided as parameters. If program fails to find one of the two methods, it will ask to insert from CLI.

The file `fr_credentials.env` is like:
```
FR_EMAIL=some@email.com
FR_PASS=mysecretpassword
FR_UID=AXXXXXXXXXXXXXXXXXX
```

The Unique ID is required for some Device related commands and therefore has been added also here and it is added to the output file `fr_session.env` as well.

Freedom documentation [here](https://docs.freedomrobotics.ai/reference/login)

## Logout

Logout action destroy a couple of `mc_token` and `mc_secret`. For the script to log you out it is required the secret and the token to revoke and the user email.

The script automatically search for `fr_credentials.env` and `fr_session.env` and it deletes the last if the logout has succedeed.

Freedom documentation [here](https://docs.freedomrobotics.ai/reference/logout)
