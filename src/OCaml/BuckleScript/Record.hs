{-|
Module      : OCaml.BuckleScript.Record
Description : Create OCaml data types from Haskell data types
Copyright   : Plow Technologies, 2017
License     : BSD3
Maintainer  : mchaver@gmail.com
Stability   : experimental

For a Haskell type with an instance of OCamlType, output the
OCaml type declaration.
-}

{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module OCaml.BuckleScript.Record
  ( toOCamlTypeSourceWith
  ) where

-- base
import Control.Monad.Reader
import Data.List (nub, sort)
import Data.Maybe (catMaybes)
import Data.Monoid
import Data.Proxy (Proxy (..))
import Data.Typeable

-- containers
import qualified Data.Map.Strict as Map

-- ocaml-export
import OCaml.BuckleScript.Types
import OCaml.Internal.Common

-- text
import Data.Text (Text)
import qualified Data.Text as T

-- wl-pprint
import Text.PrettyPrint.Leijen.Text hiding ((<$>), (<>))

-- | render a Haskell data type in OCaml
class HasType a where
  render :: a -> Reader TypeMetaData Doc

class HasRecordType a where
  renderRecord :: a -> Reader TypeMetaData Doc

class HasTypeRef a where
  renderRef :: a -> Reader TypeMetaData Doc

instance HasType OCamlDatatype where
  render datatype@(OCamlDatatype _mOCamlTypeDataType typeName constructor@(OCamlSumOfRecordConstructor _ (MultipleConstructors constructors))) = do
    -- For each constructor, if it is a record constructor, declare a type for that record
    -- before and separate from the main sum type.
    sumRecordsData <- catMaybes <$> sequence (renderSumRecord typeName <$> constructors)
    let sumRecords = msuffix (line <> line) (fst <$> sumRecordsData)
        newConstructors = replaceRecordConstructors (snd <$> sumRecordsData) <$> constructors
        typeParameters = renderTypeParameters constructor
    fnName <- renderRef datatype
    fnBody <- render (OCamlValueConstructor $ MultipleConstructors newConstructors)
    pure $ sumRecords <> ("type" <+> typeParameters <+> fnName <+> "=" <$$> indent 2 ("|" <+> fnBody))

  render datatype@(OCamlDatatype _ _ constructor@(OCamlValueConstructor (RecordConstructor _ _))) = do
    let typeParameters = renderTypeParameters constructor
    fnName <- renderRef datatype
    fnBody <- render constructor
    pure $ "type" <+> typeParameters <+> fnName <+> "=" <$$> indent 2 fnBody

  render datatype@(OCamlDatatype _ _ constructor) = do
    let typeParameters = renderTypeParameters constructor
    fnName <- renderRef datatype
    fnBody <- render constructor
    pure $ "type" <+> typeParameters <+> fnName <+> "=" <$$> indent 2 ("|" <+> fnBody)

  render (OCamlPrimitive primitive) = renderRef primitive

instance HasTypeRef OCamlDatatype where
  renderRef (OCamlDatatype typeRef typeName (OCamlValueConstructor (NamedConstructor _ (OCamlRefApp typRep values)))) = do
    dx <- renderRef values
    pure $ (parens dx) <+> (stext . textLowercaseFirst . T.pack . show $ typeRepTyCon typRep)

  renderRef datatype@(OCamlDatatype typeRef typeName _) = do
    if isTypeParameterRef datatype
    then
      pure . stext $ "'" <> textLowercaseFirst typeName
    else do
      mOCamlTypeMetaData <- asks topLevelOCamlTypeMetaData 
      case mOCamlTypeMetaData of
        Nothing -> pure . stext . textLowercaseFirst $ typeName

        Just decOCamlTypeMetaData -> do
          ds <- asks (dependencies . userOptions)
          case Map.lookup typeRef ds of
            Just parOCamlTypeMetaData -> do
              let prefix = stext $ mkModulePrefix decOCamlTypeMetaData parOCamlTypeMetaData
              pure $ prefix <> (stext . textLowercaseFirst $ typeName)
            Nothing -> fail ("expected to find dependency:\n\n" ++ show typeRef ++ "\n\nin\n\n" ++ show ds)

  renderRef (OCamlPrimitive primitive) = renderRef primitive

instance HasTypeRef OCamlValue where
  renderRef (Values x y) = do
    dx <- render x
    dy <- render y
    pure $ dx <+> dy

  renderRef _ = pure ""  
            
instance HasType OCamlConstructor where
  render (OCamlValueConstructor value) = render value
  render (OCamlSumOfRecordConstructor _ value) = render value
  render (OCamlEnumeratorConstructor constructors) = do
    mintercalate (line <> "|" <> space) <$> sequence (render <$> constructors)

instance HasType ValueConstructor where
  -- record
  render (RecordConstructor _ value) = do
    fields <- renderRecord value
    pure $ "{" <+> fields <$$> "}"

  -- enumerator
  render (NamedConstructor constructorName (OCamlEmpty)) = do
    pure $ stext constructorName

  -- product
  render (NamedConstructor constructorName value) = do
    types <- render value
    pure $ stext constructorName <+> "of" <+> types

  -- sum
  render (MultipleConstructors constructors) = do
    mintercalate (line <> "|" <> space) <$> sequence (render <$> constructors)

instance HasType EnumeratorConstructor where
  render (EnumeratorConstructor name) = pure (stext name)
  
instance HasType OCamlValue where
  render ref@(OCamlRef typeRef name) = do
    mOCamlTypeMetaData <- asks topLevelOCamlTypeMetaData
    case mOCamlTypeMetaData of
      Nothing -> fail $ "OCaml.BuckleScript.Record (HasType (OCamlDatatype typeRep name)) mOCamlTypeMetaData is Nothing:\n\n" ++ (show ref)
      Just ocamlTypeRef -> do
        ds <- asks (dependencies . userOptions)
        pure . stext $ appendModule ds ocamlTypeRef typeRef name

  render ref@(OCamlRefApp typRep values) = do
    dx <- renderRef values
    pure $ (parens dx) <+> (stext . textLowercaseFirst . T.pack . show $ typeRepTyCon typRep)

  render (OCamlTypeParameterRef name) = pure (stext ("'" <> name))
  render (OCamlPrimitiveRef primitive) = ocamlRefParens primitive <$> renderRef primitive
  render OCamlEmpty = pure (text "")
  render (Values x y) = do
    dx <- render x
    dy <- render y
    return $ dx <+> "*" <+> dy
  render (OCamlField name value) = do
    dv <- renderRecord value
    return $ stext name <+> ":" <+> dv


instance HasRecordType OCamlValue where
  renderRecord (OCamlPrimitiveRef primitive) = renderRef primitive
  renderRecord (Values x y) = do
    dx <- renderRecord x
    dy <- renderRecord y
    return $ dx <$$> ";" <+> dy
  renderRecord value = render value

instance HasTypeRef OCamlPrimitive where
  renderRef (OList (OCamlPrimitive OChar)) = renderRef OString
  renderRef (OList datatype) = do
    dt <- renderRef datatype
    return $ parens dt <+> "list"
  renderRef (OTuple2 a b) = do
    da <- renderRef a
    db <- renderRef b
    return . parens $ da <+> "*" <+> db
  renderRef (OTuple3 a b c) = do
    da <- renderRef a
    db <- renderRef b
    dc <- renderRef c
    return . parens $ da <+> "*" <+> db <+> "*" <+> dc
  renderRef (OTuple4 a b c d) = do
    da <- renderRef a
    db <- renderRef b
    dc <- renderRef c
    dd <- renderRef d
    return . parens $ da <+> "*" <+> db <+> "*" <+> dc <+> "*" <+> dd
  renderRef (OTuple5 a b c d e) = do
    da <- renderRef a
    db <- renderRef b
    dc <- renderRef c
    dd <- renderRef d
    de <- renderRef e
    return . parens $ da <+> "*" <+> db <+> "*" <+> dc <+> "*" <+> dd <+> "*" <+> de
  renderRef (OTuple6 a b c d e f) = do
    da <- renderRef a
    db <- renderRef b
    dc <- renderRef c
    dd <- renderRef d
    de <- renderRef e
    df <- renderRef f
    return . parens $ da <+> "*" <+> db <+> "*" <+> dc <+> "*" <+> dd <+> "*" <+> de <+> "*" <+> df
  renderRef (OOption datatype) = do
    dt <- renderRef datatype
    return $ parens dt <+> "option"
  renderRef (OEither k v) = do
    dk <- renderRef k
    dv <- renderRef v
    return $ (parens $ dk <> "," <+> dv) <+> "Aeson.Compatibility.Either.t"
  renderRef OInt    = pure "int"
  renderRef ODate   = pure "Js_date.t"
  renderRef OBool   = pure "bool"
  renderRef OChar   = pure "string"
  renderRef OString = pure "string"
  renderRef OUnit   = pure "unit"
  renderRef OFloat  = pure "float"

-- Util functions

-- | A Haskell Sum of Records needs to be transformed into OCaml record types
--   and a sum type. Replace RecordConstructor with NamedConstructor.
replaceRecordConstructors :: [(Text,ValueConstructor)] -> ValueConstructor -> ValueConstructor
replaceRecordConstructors newConstructors recordConstructor@(RecordConstructor oldName _) = 
  case length newRecordConstructor > 0 of
    False -> recordConstructor
    True  -> head newRecordConstructor
  where
    replace (oldName', (RecordConstructor newName _value)) =
      if oldName == oldName' then (Just $ NamedConstructor oldName' (OCamlRef (HaskellTypeMetaData "" "" "") newName)) else Nothing
    replace _ = Nothing
    newRecordConstructor = catMaybes $ replace <$> newConstructors

replaceRecordConstructors _ rc = rc

-- | Given a constructor, output a list of type parameters.
--   (Maybe a) -> 'a0 list -> ["'a0"]
--   (Either a b) -> 'a0 'a1 list -> ["'a0","'a1"]
renderTypeParameters :: OCamlConstructor -> Doc
renderTypeParameters constructor = mkDocList $ stext . (<>) "'" <$> sort (nub $ getTypeParameters constructor)

-- | For Haskell Sum of Records, create OCaml record types of each RecordConstructor
renderSumRecord :: Text -> ValueConstructor -> Reader TypeMetaData (Maybe (Doc,(Text,ValueConstructor)))
renderSumRecord typeName constructor@(RecordConstructor name value) = do
  let sumRecordName = typeName <> name
  functionBody <- render constructor
  pure $ Just (("type" <+> (stext (textLowercaseFirst sumRecordName)) <+> "=" <$$> indent 2 functionBody), (name, (RecordConstructor sumRecordName value)))
renderSumRecord _ _ = return Nothing

-- | Puts parentheses around the doc of an OCaml ref if it contains spaces.
ocamlRefParens :: OCamlPrimitive -> Doc -> Doc
ocamlRefParens (OList (OCamlPrimitive OChar)) = id
ocamlRefParens (OList _) = parens
ocamlRefParens (OOption _) = parens
ocamlRefParens _ = id

-- | Convert a 'Proxy a' into OCaml type source code.
toOCamlTypeSourceWith :: forall a. OCamlType a => Options -> a -> T.Text
toOCamlTypeSourceWith options a =
  case toOCamlType (Proxy :: Proxy a) of
    OCamlDatatype haskellTypeMetaData _ _ ->
      case Map.lookup haskellTypeMetaData (dependencies options) of
        Just ocamlTypeMetaData -> pprinter $ runReader (render (toOCamlType a)) (TypeMetaData (Just ocamlTypeMetaData) options)
        Nothing -> ""
    _ -> pprinter $ runReader (render (toOCamlType a)) (TypeMetaData Nothing options)

-- | If this type comes from a different OCaml module, then add the appropriate module prefix
appendModule :: Map.Map HaskellTypeMetaData OCamlTypeMetaData -> OCamlTypeMetaData -> HaskellTypeMetaData -> Text -> Text
appendModule m o h name =
  case Map.lookup h m of
    Just parOCamlTypeMetaData -> 
      (mkModulePrefix o parOCamlTypeMetaData) <> (textLowercaseFirst name)
    -- in case of a Haskell sum of products, ocaml-export creates a definition for each product
    -- within the same file as the sum. These products will not be in the dependencies map.
    Nothing -> textLowercaseFirst name

-- | for records (of non-primitive types) with type parameters, write the corresponding OCaml types.
--   This uses TypeRep instead of data derived from Generics.
{-
renderRowTypeParameters
  :: Map.Map HaskellTypeMetaData OCamlTypeMetaData
  -> OCamlTypeMetaData
  -> TypeRep
  -> Text
renderRowTypeParameters m o t =
  case Map.lookup hd tupleTyConToSize of
    Just _ -> "(" <> (T.intercalate " * " $ (\x -> (renderRowTypeParameters m o x)) <$> rst) <> ")"
    Nothing -> 
      if length rst == 0
      then typeParameters
      else
        if typeRepIsString t
        then "string"
        else "(" <> (T.intercalate ", " $ (\x -> (renderRowTypeParameters m o x)) <$> rst) <> ") " <> typeParameters
  where
  (hd,rst) = splitTyConApp $ t
  typeParameters =
    case Map.lookup hd typeParameterRefTyConToOCamlTypeText of
      Just ptyp -> "'" <> ptyp
      Nothing -> 
        case Map.lookup hd primitiveTyConToOCamlTypeText of
          Just "either" -> "Aeson.Compatibility.Either.t"
          Just typ -> typ
          Nothing  -> appendModule m o (typeRepToHaskellTypeMetaData t) (T.pack . show $ hd)

a -> Reader TypeMetaData Doc

appendModule :: Map.Map HaskellTypeMetaData OCamlTypeMetaData -> OCamlTypeMetaData -> HaskellTypeMetaData -> Text -> Text
appendModule m o h name =
  case Map.lookup h m of
    Just parOCamlTypeMetaData -> 
      (mkModulePrefix o parOCamlTypeMetaData) <> (textLowercaseFirst name)
    -- in case of a Haskell sum of products, ocaml-export creates a definition for each product
    -- within the same file as the sum. These products will not be in the dependencies map.
    Nothing -> textLowercaseFirst name

typeRepToHaskellTypeMetaData
-}
renderRowTypeParameters
  :: Map.Map HaskellTypeMetaData OCamlTypeMetaData
  -> TypeRep
  -> Reader TypeMetaData Doc
renderRowTypeParameters m t =
  if length rst == 0
  then pure $ stext typeParameters
  else
    if typeRepIsString t
    then pure $ "string"
    else do
      docs <- mkDocListP <$> (sequence $ ((\x -> renderRowTypeParameters m x) <$> rst))
      pure $ docs <+> stext typeParameters 

  where
    (hd,rst) = splitTyConApp $ t
    haskellTypeMetaData = tyConToHaskellTypeMetaData hd
    typeParameters =
      case Map.lookup hd typeParameterRefTyConToOCamlTypeText of
        Just ptyp -> "'" <> ptyp
        Nothing -> 
          case Map.lookup hd primitiveTyConToOCamlTypeText of
            Just "either" -> "Aeson.Compatibility.Either.t"
            Just typ -> typ
            Nothing  ->
              case Map.lookup haskellTypeMetaData m of
                Nothing -> "not found"
                Just o -> appendModule m o (typeRepToHaskellTypeMetaData t) (T.pack . show $ hd)
