# dart-pubgrub-example

Clone `pub` git repository:

    git clone https://github.com/dart-lang/pub.git

Install packages:

    dart pub get

Setup temp folder:

    mkdir -p temp/myapp

Start test case:

    dart run main.dart

This command will:
* start a package server that hosts the packages of the test case
* create the file `temp/myapp/pubspec.yaml` describing the root dependencies

In a new Terminal, solve packages, use the port number (e.g. `50615`) from the previous output:

    bash run_pub.sh 50615
