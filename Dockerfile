FROM swiftlang/swift:nightly-6.4.x-noble

RUN apt-get update
RUN apt-get -y install libxml2-dev curl gnupg
RUN curl -sL https://deb.nodesource.com/setup_26.x | bash -
RUN apt-get -y install nodejs
# No netlify-cli here on purpose. It used to live in this image, which made
# deploys silently depend on it -- when the image was rebuilt and pushed
# without the layer on 2026-08-04, every deploy broke with `netlify: not found`
# for 13 days while the Dockerfile still claimed to install it. CI now installs
# a pinned CLI in the deploy job itself. Node stays: the publish pipeline's
# final step shells out to npm to build Styling/.
