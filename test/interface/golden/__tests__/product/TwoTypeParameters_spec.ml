let () =
  AesonSpec.sampleGoldenAndServerSpec (TwoTypeParameters.decodeTwoTypeParameters (fun (x : Js_json.t) -> Aeson.Decode.wrapResult (Aeson.Decode.singleEnumerator Aeson.Helper.TypeParameterRef0) x) (fun (x : Js_json.t) -> Aeson.Decode.wrapResult (Aeson.Decode.singleEnumerator Aeson.Helper.TypeParameterRef1) x)) (TwoTypeParameters.encodeTwoTypeParameters (fun _x -> Aeson.Encode.singleEnumerator Aeson.Helper.TypeParameterRef0) (fun _x -> Aeson.Encode.singleEnumerator Aeson.Helper.TypeParameterRef1)) "twoTypeParameters" "http://localhost:8081/TwoTypeParameters/TwoTypeParameters" "golden/product/TwoTypeParameters.json";
