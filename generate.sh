#!/bin/bash
echo "GENERATING SWOOLE STUBS:"
echo "---------------------"
ini_path="./config.ini"
echo "loading config... '$ini_path'"
. $ini_path
if [[ -z $swoole_version ]]
then
    echo "no 'swoole_version' configured, create a config.ini in the same directory as $0 with this setting"
fi
if [[ -z $php_extension_stub_generator_version ]]
then
    echo "no 'php_extension_stub_generator_version' configured, create a config.ini in the same directory as $0 with this setting"
fi
image_name="stg-s$swoole_version-g$php_extension_stub_generator_version"
container_name=$image_name"i"
echo "building image named '$image_name'... please wait"
image_id=\
$(docker build \
    --build-arg swoole_version=$swoole_version \
    --build-arg php_extension_stub_generator_version=$php_extension_stub_generator_version \
    -q -t $image_name . \
)
if [[ -z $image_id ]]
then
    echo "building image '$image_name' failed EXITED"
    exit 1
fi
echo "build complete..."
echo "starting a container as '$container_name'..."
container_id=$(docker run -d --rm --name $container_name $image_id)
if [[ -z $container_id ]]
then
    echo "running $image_name as '$container_name' failed EXITED"
    exit 1
fi
echo "container is running..."
if [[ -d './src' ]]
then
    echo "deleting existing ./src directory..."
    if rm -rf ./src
    then
        echo "successfully deleted existing ./src directory..."
    else
        echo "failed to delete existing ./src directory..."
    fi    
fi
echo "copying files from container..."
if ! docker cp $container_id:/util/php-extension-stub-generator-wrapper/src .
then
    echo "failed to copy files from container... EXITED"
    exit 1
fi
echo "successfully copied generated PHP stub files from container to './src'..."
if ! docker container stop $container_id >/dev/null
then
    echo "failed to stop container '$container_id'... CONTINUING"
else
    echo "stopped container '$container_id'..."
fi
echo "packaging PhpStorm autocomplete plugin..."
if [[ -d './tmp/template' ]]
then
    rm -rf tmp/template/* && rm -d tmp/template
fi
if ! cp -R template tmp
then
    echo "failed to copy template to tmp dir... EXITED"
    exit 1
fi
if ! cp -R src/ tmp/template/swoole/
then
    echo "failed to copy PHP stub files to tmp dir... EXITED"
    exit 1
fi
timestamp() {
  date +"%Y-%m-%d %T"
}
echo "customizing plugin based on versions defined in $ini_path..."
current_datetime=$(timestamp)
sed -i '' -e "s/{{swoole_version}}/$swoole_version/g" tmp/template/META-INF/plugin.xml
sed -i '' -e "s/{{timestamp}}/$current_datetime/g" tmp/template/META-INF/plugin.xml
plugin_filename="phpstorm-swoole-stubs-$swoole_version-plugin.jar"
$(cd tmp/template && zip -r p.jar * >/dev/null && mv p.jar ./../../$plugin_filename)
echo "generated plugin file $plugin_filename..."
echo "cleaning up..."
if [[ -d './tmp/template' ]]
then
    rm -rf tmp/template/* && rm -d tmp/template
fi
echo "DONE"