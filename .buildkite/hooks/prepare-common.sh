#!/usr/bin/env bash
set -eo pipefail

# Configure the java version
JAVA_VERSION=$(cat .java-version | xargs | tr -dc '[:print:]')
set +u
# In case the HOME is not available in the context of the runner.
if [ -z "${HOME}" ] ; then
  HOME="${BUILDKITE_BUILD_CHECKOUT_PATH}"
  export HOME
fi
JAVA_HOME="${HOME}/.java/openjdk${JAVA_VERSION}"
set -u

export JAVA_HOME
PATH="${JAVA_HOME}/bin:${PATH}"
export PATH

if [ -d "${JAVA_HOME}" ] ; then
  echo "--- Skip installing JDK${JAVA_VERSION} :java:"
  echo "already available in the Buildkite runner"
else
  # Fallback to install at runtime
  # This should not be the case normally untless the .java-version file has been changed
  # and the VM Image is not yet available with the latest version.
  echo "--- Install JDK${JAVA_VERSION} :java:"
  JAVA_URL=https://jvm-catalog.elastic.co/jdk
  JAVA_PKG="${JAVA_URL}/latest_openjdk_${JAVA_VERSION}_linux.tar.gz"
  curl -L --output /tmp/jdk.tar.gz "${JAVA_PKG}"
  mkdir -p "${JAVA_HOME}"
  tar --extract --file /tmp/jdk.tar.gz --directory "${JAVA_HOME}" --strip-components 1
fi

# Validate java is available in the runner.
java -version
