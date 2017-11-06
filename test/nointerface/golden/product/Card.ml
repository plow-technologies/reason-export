type suit =
  | Clubs
  | Diamonds
  | Hearts
  | Spades

let encodeSuit (x : suit) :Js_json.t =
  match x with
  | Clubs ->
     Json.Encode.string "Clubs"
  | Diamonds ->
     Json.Encode.string "Diamonds"
  | Hearts ->
     Json.Encode.string "Hearts"
  | Spades ->
     Json.Encode.string "Spades"

let decodeSuit (json : Js_json.t) :(suit, string) Js_result.t =
  match Js_json.decodeString json with
  | Some "Clubs" -> Js_result.Ok Clubs
  | Some "Diamonds" -> Js_result.Ok Diamonds
  | Some "Hearts" -> Js_result.Ok Hearts
  | Some "Spades" -> Js_result.Ok Spades
  | Some err -> Js_result.Error ("decodeSuit: unknown enumeration '" ^ err ^ "'.")
  | None -> Js_result.Error "decodeSuit: expected a top-level JSON string."

type card =
  { cardSuit : suit
  ; cardValue : int
  }

let encodeCard (x : card) :Js_json.t =
  Json.Encode.object_
    [ ( "cardSuit", encodeSuit x.cardSuit )
    ; ( "cardValue", Json.Encode.int x.cardValue )
    ]

let decodeCard (json : Js_json.t) :(card, string) Js_result.t =
  match Json.Decode.
    { cardSuit = field "cardSuit" (fun a -> unwrapResult (decodeSuit a)) json
    ; cardValue = field "cardValue" int json
    }
  with
  | v -> Js_result.Ok v
  | exception Json.Decode.DecodeError message -> Js_result.Error ("decodeCard: " ^ message)
