FROM swiftlang/swift:nightly-6.4.x-noble

RUN apt-get update
RUN apt-get -y install libxml2-dev curl gnupg
RUN curl -sL https://deb.nodesource.com/setup_26.x | bash -
RUN apt-get -y install nodejs
RUN npm i -g --unsafe-perm=true netlify-cli
