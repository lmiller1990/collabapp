poetry run pip install --upgrade -t package dist/*.whl --only-binary=:all: --python-version 3.12 --platform manylinux2014_x86_64
cp -r collab package/
cd package ; zip -r ../lambda.zip . -x '*.pyc'
