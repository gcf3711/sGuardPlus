# sha1-file

[![NPM version][npm-image]][npm-url]
[![Build status][travis-image]][travis-url]
[![License][license-image]][license-url]
[![Code style][standard-image]][standard-url]

> Simply return an `sha1` sum of a given file. If using async version (by including callback), it will stream; successfully tested on files 4 GB+.

### Installation

```
$ npm install --save sha1-file
```

### Usage

__sha1File(path, [callback])__

```javascript
const sha1File = require('sha1-file')

// sync (no callback)

sha1File('./path/to/a_file') // 'c8a2e2125f94492082bc484044edb4dc837f83b'

// async/streamed (if using callback)

sha1File('./path/to/a_file', function (error, sum) {
  if (error) {
    console.log(error)
  }

  console.log(sum) // 'c8a2e2125f94492082bc484044edb4dc837f83b'
})
```

### Caveats

When using the _sync_ version (excluding the callback), you will be limited to
a filesize of 2GB (1GB on 32-bit platforms), this is due to a *V8* restriction,
see [this issue](https://github.com/nodejs/node/issues/1719) for more details.

[npm-image]: https://img.shields.io/npm/v/sha1-file.svg
[npm-url]: https://npmjs.org/package/sha1-file
[travis-image]: https://img.shields.io/travis/roryrjb/sha1-file.svg
[travis-url]: https://travis-ci.org/roryrjb/sha1-file
[license-image]: http://img.shields.io/npm/l/sha1-file.svg
[license-url]: LICENSE
[standard-image]: https://img.shields.io/badge/code%20style-standard-brightgreen.svg
[standard-url]: https://github.com/feross/standard
