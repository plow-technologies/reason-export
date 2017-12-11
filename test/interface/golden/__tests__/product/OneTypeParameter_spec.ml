let () =
  AesonSpec.sampleGoldenAndServerSpec (OneTypeParameter.decodeOneTypeParameter (fun (x : Js_json.t) -> Aeson.Decode.wrapResult (Aeson.Decode.singleEnumerator Aeson.Helper.TypeParameterRef0) x)) (OneTypeParameter.encodeOneTypeParameter (fun _x -> Aeson.Encode.singleEnumerator Aeson.Helper.TypeParameterRef0)) "oneTypeParameter" "http://localhost:8081/OneTypeParameter/OneTypeParameter" "golden/product/OneTypeParameter";
