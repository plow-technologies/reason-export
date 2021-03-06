let () =
  AesonSpec.sampleGoldenAndServerSpec
    (Wrapper.decodeWrapper AesonSpec.decodeIntWithResult)
    (Wrapper.encodeWrapper Aeson.Encode.int)
    "wrapper"
    "http://localhost:8081/Wrapper/Wrapper"
    "golden/product/Wrapper";

  AesonSpec.sampleGoldenAndServerSpec
    Wrapper.decodeIntWrapped
    Wrapper.encodeIntWrapped
    "intWrapped"
    "http://localhost:8081/Wrapper/IntWrapped"
    "golden/product/IntWrapped";

  AesonSpec.sampleGoldenAndServerSpec
    Wrapper.decodeMaybeWrapped
    Wrapper.encodeMaybeWrapped
    "maybeWrapped"
    "http://localhost:8081/Wrapper/MaybeWrapped"
    "golden/product/MaybeWrapped";

  AesonSpec.sampleGoldenAndServerSpec
    Wrapper.decodeEitherWrapped
    Wrapper.encodeEitherWrapped
    "eitherWrapped"
    "http://localhost:8081/Wrapper/EitherWrapped"
    "golden/product/EitherWrapped";

  AesonSpec.sampleGoldenAndServerSpec
    Wrapper.decodeComplexWrapped
    Wrapper.encodeComplexWrapped
    "complexWrapped"
    "http://localhost:8081/Wrapper/ComplexWrapped"
    "golden/product/ComplexWrapped";

  AesonSpec.sampleGoldenAndServerSpec
    Wrapper.decodeSumWrapped
    Wrapper.encodeSumWrapped
    "sumWrapped"
    "http://localhost:8081/Wrapper/SumWrapped"
    "golden/product/SumWrapped";

  AesonSpec.sampleGoldenAndServerSpec
    Wrapper.decodeTupleWrapped
    Wrapper.encodeTupleWrapped
    "tupleWrapped"
    "http://localhost:8081/Wrapper/TupleWrapped"
    "golden/product/TupleWrapped";

  AesonSpec.sampleGoldenAndServerSpec
    (Wrapper.decodeHalfWrapped AesonSpec.decodeIntWithResult)
    (Wrapper.encodeHalfWrapped Aeson.Encode.int)
    "halfWrapped"
    "http://localhost:8081/Wrapper/HalfWrapped"
    "golden/product/HalfWrapped";

  AesonSpec.sampleGoldenAndServerSpec
    (Wrapper.decodePartiallyWrapped AesonSpec.decodeIntWithResult AesonSpec.decodeIntWithResult AesonSpec.decodeIntWithResult)
    (Wrapper.encodePartiallyWrapped Aeson.Encode.int Aeson.Encode.int Aeson.Encode.int)
    "partiallyWrapped"
    "http://localhost:8081/Wrapper/PartiallyWrapped"
    "golden/product/PartiallyWrapped";

  AesonSpec.sampleGoldenAndServerSpec
    (Wrapper.decodeScrambledTypeParameterRefs AesonSpec.decodeIntWithResult AesonSpec.decodeIntWithResult AesonSpec.decodeIntWithResult AesonSpec.decodeIntWithResult AesonSpec.decodeIntWithResult AesonSpec.decodeIntWithResult)
    (Wrapper.encodeScrambledTypeParameterRefs Aeson.Encode.int Aeson.Encode.int Aeson.Encode.int Aeson.Encode.int Aeson.Encode.int Aeson.Encode.int)
    "scrambledTypeParameterRefs"
    "http://localhost:8081/Wrapper/ScrambledTypeParameterRefs"
    "golden/product/ScrambledTypeParameterRefs";

  AesonSpec.sampleGoldenAndServerSpec
    Wrapper.decodeWrappedWrapper
    Wrapper.encodeWrappedWrapper
    "wrappedWrapper"
    "http://localhost:8081/Wrapper/WrappedWrapper"
    "golden/product/WrappedWrapper";

  AesonSpec.sampleGoldenAndServerSpec
    (Wrapper.decodeWrapThree AesonSpec.decodeIntWithResult AesonSpec.decodeIntWithResult AesonSpec.decodeIntWithResult)
    (Wrapper.encodeWrapThree Aeson.Encode.int Aeson.Encode.int Aeson.Encode.int)
    "wrapThree"
    "http://localhost:8081/Wrapper/WrapThree"
    "golden/product/WrapThree";

  AesonSpec.sampleGoldenAndServerSpec
    (Wrapper.decodeWrapThreeUnfilled AesonSpec.decodeIntWithResult AesonSpec.decodeIntWithResult AesonSpec.decodeIntWithResult)
    (Wrapper.encodeWrapThreeUnfilled Aeson.Encode.int Aeson.Encode.int Aeson.Encode.int)
    "wrapThreeUnfilled"
    "http://localhost:8081/Wrapper/WrapThreeUnfilled"
    "golden/product/WrapThreeUnfilled";

  AesonSpec.sampleGoldenAndServerSpec
    Wrapper.decodeWrapThreeFilled
    Wrapper.encodeWrapThreeFilled
    "wrapThreeFilled"
    "http://localhost:8081/Wrapper/WrapThreeFilled"
    "golden/product/WrapThreeFilled";

  AesonSpec.sampleGoldenAndServerSpec
    (Wrapper.decodeWrapThreePartiallyFilled AesonSpec.decodeIntWithResult)
    (Wrapper.encodeWrapThreePartiallyFilled Aeson.Encode.int)
    "wrapThreePartiallyFilled"
    "http://localhost:8081/Wrapper/WrapThreePartiallyFilled"
    "golden/product/WrapThreePartiallyFilled";
