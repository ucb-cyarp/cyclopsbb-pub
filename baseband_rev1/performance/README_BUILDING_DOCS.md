# Building HTML Versions of Documentation
This is based off the turorial at [https://code.visualstudio.com/docs/languages/markdown](https://code.visualstudio.com/docs/languages/markdown) and [https://www.npmjs.com/package/gulp-markdown](https://www.npmjs.com/package/gulp-markdown) to compile markdown to webpages.

This uses a Docker Container initialized by Visual Studio Code with the dockerfile modified to install node.js, npm, and markdown-it.

The config file is in `.devcontainer\Dockerfile`.

To build the docs call `gulp` within the `performance` directory.