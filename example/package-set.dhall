let upstream = https://github.com/dfinity/vessel-package-set/releases/download/mo-0.6.21-20220215/package-set.dhall
let additions = [
      { name = "ic-logger"
      , repo = "https://github.com/ninegua/ic-logger"
      , version = "ed33d022befe053b8cc1cc1f9a070daafa23dd50"
      , dependencies = [ "base" ]
      }
    ]
in  upstream # additions
