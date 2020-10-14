#!/bin/bash

# Copy the relevant system environment variables to the R-specific locations
VariableArray=("GIT_COMMITTER_NAME"  "GIT_AUTHOR_NAME"  "EMAIL")
for var in ${VariableArray[*]}; do
    if [ -n "${!var}" ]; then
        echo $var=${!var} >> ${HOME}/.Renviron
    fi
done

# Setup git user
if [ -z "$(git config --global --get user.name)" ]; then
    git config --global user.name "$GIT_AUTHOR_NAME"
fi
if [ -z "$(git config --global --get user.email)" ]; then
    git config --global user.email "$EMAIL"
fi

# add a symlink to the project directory in /home/rstudio
[ -n "$CI_PROJECT" ] && ln -s /work/${CI_PROJECT} /home/rstudio

# configure rstudio to open the mirailabs-2-0 project
mkdir -p /home/rstudio/.rstudio/projects_settings 
echo /home/rstudio/${CI_PROJECT}/mirailabs-2-0.Rproj | tee /home/rstudio/.rstudio/projects_settings/next-session-project
chown -R rstudio:root /home/rstudio/.rstudio/projects_settings

#
# save variables
#

export CI_PROJECT=${CI_PROJECT}

#
# copy the environment from renku-env repo
#

# clone the repo
proto=$(echo $GITLAB_URL | sed -e's,^\(.*://\).*,\1,g')
url=$(echo ${GITLAB_URL/$proto/})
user=$(echo ${CI_REPOSITORY_URL/$proto/} | grep @ | cut -d@ -f1)

git clone --depth 1 ${proto}${user}@${url}/${JUPYTERHUB_USER}/renku-env.git /tmp/renku-env || true

# append the contents of all the files to same files in ${HOME}
find /tmp/renku-env -not -path '*.git*' -type f -print0 | xargs --null -I{} sh -c 'cat {} >> ${HOME}/$(basename "{}")' || true

# copy a dummy id_rsa file for a workflow example
mkdir /home/rstudio/.ssh

printf " -----BEGIN RSA PRIVATE KEY----\n \
F6CrjwlH959kpfTnbwVfOIaALJ6BD1Tus9Uolex3\n\
jGW8u4Q9Aajm8Ebch0H1jeJSqKDHbe2AHcpd6FOu\n\
FndHqaikNK01zGlMkpIBgB0FoDZ7H1m8dA1uNuNX\n\
jzKBnc7UmGWelm63Kv7AuoiT3sMdM10u8qCqClRZ\n\
gScB05XapffcDQBfp66miAl76sj9XOotRzjQN6Ta\n\
kKHgQeWv2q4uvzlU2PayhG25DbZvhB11766rt2jA\n\
16NF5465cd27apF1gAUcvqro1wsakdb74e6y5Knp\n\
BCjZIhVaoGbhPYbXbE95bLcfRXDtQoZ82kSG4e3k\n\
JOupoYWqUFPDXm7SNj6Ru9AgOioBDMowbk0d7dt3\n\
tG6esiaqwCyMW4tuWcsorxKqZfyxrfm2E8wP8p18\n\
2euVCHLI3EE7spWoIkMdD86n7yxAPKm7KpShQUJh\n\
k8ctMS0rjf742HhHHDNd8mDvMna6NzV646bThtCd\n\
MTJwSybGt5INBIVziICMeoZbc789KzProJiX9zaO\n\
YBnF33doALzlj5F6545weTtJNt07PYSliNWvtrsV\n\
lnQ7HbSocJrvZFicVd6UABU3WsVZ9aykzH7HiEoS\n\
u0mbnR84z2IbORVr03bgd4R3rwhsmnH9ZsZqL7Pz\n\
GFdMztvSfAfb4rlnogtqInXCR6QfAT9KcUnnNXQ3\n\
aXRQmRqlxSnmimuup1eTdNTPVlSnahJ7ERFa1Rvk\n\
6CgbO4OJD1rpGPfdTXXb9TVjhh3SHbeWKOm3fqx0\n\
MUJC3965ylVAhYdID0XlXnDulULFJTJx1Yh8FuUv\n\
cSBODpmVQ3cm45B2HxmtB69yvAmsHfi7w49AFnqk\n\
bVWLArqgew5VcCDGSJH4hItX7N8AWqSzozk36sAV\n\
AwQZ2p0JSZwzrZPPBRjkkltIg9ta6tFI7sjdk4NK\n\
ajKyWoxzwsF1e1gzsN9IdVMlFuOFf9D3Y8nidLtM\n\
ejRti4lMAkoRZFcjJCFHNJO3uBJokJP8yPpunfaZ\n\
-----END RSA PRIVATE KEY-----" \
| tee /home/rstudio/.ssh/id_rsa_dummy

# run the command
$@