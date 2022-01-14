# BACKEND

Backend for SimpleAuthenticator. Implements authentication and cloud storage.

To deploy yourself, you need a MongoDB Server. Copy `.env.example` to `.env` and fill out the variables.

Run the server with `yarn dev`.

To view API documentation, install [Rest Book](https://marketplace.visualstudio.com/items?itemName=tanhakabir.rest-book) extension for [VSCode](https://code.visualstudio.com) and open the `docs.restbook` file.

## Hosted on Railway

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/new/template?template=https%3A%2F%2Fgithub.com%2Farnu515%2Fsimpleauthenticator%2Ftree%2Fmaster%2Fbackend&envs=DATABASE_URL%2CSECRET%2CJWT_SECRET&DATABASE_URLDesc=MongoDB+Url&SECRETDesc=Secret+%28Should+be+32+characters%29&JWT_SECRETDesc=JWT+Secret+%2832+Characters%29&referralCode=arnu5152)

Click the above button to deploy this backend on Railway.
