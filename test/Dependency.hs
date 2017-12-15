{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeOperators #-}

module Dependency where

import Data.Aeson (FromJSON, ToJSON)
import Data.Monoid ((<>))
import Data.Proxy
import Data.Text (Text)
import Data.Time
import Data.Time.Clock.POSIX
import Data.Map as Map
import GHC.Generics
import OCaml.Export
import Test.Hspec
import Test.QuickCheck
import Test.QuickCheck.Arbitrary.ADT
import Test.Aeson.Internal.ADT.GoldenSpecs
import Util

import Product (ProductPackage, Person)

mkGolden :: forall a. (ToADTArbitrary a, ToJSON a) => Proxy a -> IO ()
mkGolden Proxy = mkGoldenFileForType 10 (Proxy :: Proxy a) "test/interface/golden/golden/dependency"

mkGoldenFiles :: IO ()
mkGoldenFiles = do
  mkGolden (Proxy :: Proxy Class)

type DependencyPackage
  =    OCamlPackage "dependency" '[ProductPackage] :> (
       OCamlModule '["Class"] :> Class)

type DependencyPackageWithoutProduct
  =    OCamlPackage "dependency" NoDependency :> (
       OCamlModule '["Class"] :> Class)
{-
data Person = Person
  { id :: Int
  , name :: Maybe String
  } deriving (Show, Eq, Generic, OCamlType, FromJSON, ToJSON)

instance Arbitrary Person where
  arbitrary = Person <$> arbitrary <*> arbitrary

instance ToADTArbitrary Person
-}
data Class = Class
  { subject   :: String
  , students  :: [Person] -- from another package
  , professor :: Person
  } deriving (Show, Eq, Generic, OCamlType, FromJSON, ToJSON)

instance Arbitrary Class where
  arbitrary = do
    k <- choose (1,3)
    v <- vector k
    Class <$> arbitrary <*> pure v <*> arbitrary

instance ToADTArbitrary Class

spec :: Spec
spec = do
  runIO $ mkGoldenFiles
  let dir = "test/interface/temp"
  runIO $ mkPackage (Proxy :: Proxy DependencyPackage) (PackageOptions dir "dependency" Map.empty True Nothing)
  
  return ()
