let () =
  AesonSpec.sampleGoldenAndServerSpec (ThreeTypeParameters.decodeThree (fun (x : Js_json.t) -> Aeson.Decode.wrapResult (Aeson.Decode.singleEnumerator Aeson.Helper.TypeParameterRef0) x) (fun (x : Js_json.t) -> Aeson.Decode.wrapResult (Aeson.Decode.singleEnumerator Aeson.Helper.TypeParameterRef1) x) (fun (x : Js_json.t) -> Aeson.Decode.wrapResult (Aeson.Decode.singleEnumerator Aeson.Helper.TypeParameterRef2) x)) (ThreeTypeParameters.encodeThree (fun _x -> Aeson.Encode.singleEnumerator Aeson.Helper.TypeParameterRef0) (fun _x -> Aeson.Encode.singleEnumerator Aeson.Helper.TypeParameterRef1) (fun _x -> Aeson.Encode.singleEnumerator Aeson.Helper.TypeParameterRef2)) "three" "http://localhost:8081/ThreeTypeParameters/Three" "golden/product/Three.json";
