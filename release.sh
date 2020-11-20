#!/bin/bash

set -eu

VERSION=$(bundle exec ruby -e 'puts OSA::VERSION')
echo -n "Releasing ${VERSION}. Continue? (Y/n) "
read -r CONTINUE

if [ "$CONTINUE" != "y" ] && [ "$CONTINUE" != "Y" ]
then
  echo "Aborting release." >&2
  exit 1
fi

rake release
echo "Waiting for gem to be available..."
while ! (gem info -r osa --all | grep "${VERSION}")
do
  sleep 5
done

docker build . --build-arg "OSA_VERSION=${VERSION}" -t "moray95/osa:${VERSION}"
docker push "moray95/osa:${VERSION}"
