{-# LANGUAGE OverloadedStrings #-}

module OCaml.File
  ( Spec(..)
  , specsToDir
  ) where

import           Data.List
import           Data.Monoid
import           Data.Text        (Text)
import qualified Data.Text        as T
import qualified Data.Text.IO     as T
import           Formatting       as F
import           System.Directory

makePath :: [Text] -> Text
makePath = T.intercalate "/"

data Spec = Spec
  { sPath        :: [Text]
  , declarations :: [Text]
  }

pathForSpec :: FilePath -> Spec -> [Text]
pathForSpec rootDir spec = T.pack rootDir : sPath spec

ensureDirectory :: FilePath -> Spec -> IO ()
ensureDirectory rootDir spec =
  let dir = makePath . Data.List.init $ pathForSpec rootDir spec
  in createDirectoryIfMissing True (T.unpack dir)

specToFile :: FilePath -> Spec -> IO ()
specToFile rootDir spec =
  let path = pathForSpec rootDir spec
      file = makePath path <> ".ml"
      body =
        T.intercalate
          "\n\n"
          (declarations spec)
  in do fprint ("Writing: " % F.stext % "\n") file
        T.writeFile (T.unpack file) body

specsToDir :: [Spec] -> FilePath -> IO ()
specsToDir specs rootDir = mapM_ processSpec specs
  where
    processSpec = ensureDirectory rootDir >> specToFile rootDir
