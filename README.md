# dart-pubgrub-example

Run simple test cases using `pub`'s version solver PubGrub.

## Setup

First you have to install the current [Dart SDK](https://dart.dev/get-dart).

Then, clone the `pub` git repository into the subdirectory `pub`:

    git clone https://github.com/dart-lang/pub.git

Install dependencies:

    dart pub get

## Run

Run test cases:

    bash run_main.sh

Debug `main.dart` using VS Code to inspect what is happening inside the PubGrub algorithm.
