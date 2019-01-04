# Swoole stubs generator

## Purpose
Generates autocomplete PHP stubs specifically for the desired version of the Swoole extension that you are using.
But can easily be modified to generate stubs for other extensions as well by modifying the extension that gets
passed to the generator in the Dockerfile.

## Usage
1. configure the desired Swoole version in config.ini
2. run generate.sh
3. all stub PHP files can be found in the src directory after running generate.sh
4. a PhpStorm stubs plugin .jar is generated

## Requirements
- Docker
- Bash