Js.log "Hello"

module Option = struct
  let map (f: 'a -> 'b) (o: 'a option) =
    match o with
    | None   -> None
    | Some x -> Some (f x)
    
  let default (f: 'a) (o: 'a option) =
    match o with
    | None   -> f
    | Some x -> x    
end

     
type person =
  { id: int
  ; name: string
  }

let encodePerson (x: person) =
  Json.Encode.object_
    [ ("id", Json.Encode.int x.id)
    ; ("name", Json.Encode.string x.name)
    ]

type person2 =
  { id: int
  ; name: string option
  }

let encodePerson2 (x: person2) =
  Json.Encode.object_
    [ ("id", Json.Encode.int x.id)
    ; ("name", (fun xx -> Option.default Json.Encode.null (Option.map Json.Encode.string xx)) x.name)
    ]

type thing =
  | First
  | Second

type ttuple = int * string

type thing2 =
  | ABC of int
  | DEF of int * string

type company =
  { address : string
  ; employees : (person) list
  }


let encodeCompany (x : company) =
  Json.Encode.object_
    [ ( "address", Json.Encode.string x.address )
    ; ( "employees", (Json.Encode.list encodePerson) x.employees )
    ]
         
type onOrOff =
  | On
  | Off

let encodeOnOrOff (x : onOrOff) =
  match x with
  | On ->
     Json.Encode.string "On"
  | Off ->
     Json.Encode.string "Off"


type nameOrIdNumber =
  | Name of string
  | IdNumber of int

let encodeNameOrIdNumber (x : nameOrIdNumber) =
  match x with
  | Name a ->
     Json.Encode.object_
       [ ("tag", Json.Encode.string "Name")
       ; ( "contents", Json.Encode.string a )
       ]
  | IdNumber a ->
     Json.Encode.object_
       [ ("tag", Json.Encode.string "Name")
       ; ( "contents", Json.Encode.int a )
       ]

type sumVariant =
  | HasNothing
  | HasSingleInt of int
  | HasSingleTuple of (int * int)
  | HasMultipleInts of int * int
  | HasMultipleTuples of (int * int) * (int * int)

let encodeSumVariant (x : sumVariant) =
  match x with
  | HasNothing ->
     Json.Encode.object_
       [ ( "tag", Json.Encode.string "HasNothing" )
       ]
  | HasSingleInt (y0) ->
     Json.Encode.object_
       [ ( "tag", Json.Encode.string "HasSingleInt" )
       ; ( "contents", Json.Encode.int y0 )
       ]
  | HasSingleTuple (y0) ->
     Json.Encode.object_
       [ ( "tag", Json.Encode.string "HasSingleTuple" )
       ; ( "contents", (fun (a,b) -> Json.Encode.array [| Json.Encode.int a ; Json.Encode.int b  |]) y0 )
       ]
  | HasMultipleInts (y0,y1) ->
     Json.Encode.object_
       [ ( "tag", Json.Encode.string "HasMultipleInts" )
       ; ( "contents", Json.Encode.array [|Json.Encode.int y0 ; Json.Encode.int y1  |] )
       ]
  | HasMultipleTuples (y0,y1) ->
     Json.Encode.object_
       [ ("tag", Json.Encode.string "HasMultipleInts")
       ; ( "contents", Json.Encode.array [| (fun (a,b) -> Json.Encode.array [| Json.Encode.int a ; Json.Encode.int b  |]) y0 ; (fun (a,b) -> Json.Encode.array [| Json.Encode.int a ; Json.Encode.int b  |]) y1 |] )
       ]

let x = Json.Encode.array [| Json.Encode.int 1 ; Json.Encode.string "asdf" |]
let y = [1 ; 2 ]
let z = [ Json.Encode.int 1 ; Json.Encode.int 2 ; Json.Encode.string "asdf" ]

type tuple =
  int * int

let encodeTuple (x : tuple) =
  (fun (a,b) -> Json.Encode.array [| Json.Encode.int a ; Json.Encode.int b |]) x

type withTuple =
  | WithTuple of (int * int)

let encodeWithTuple (x : withTuple) =
  match x with
  | WithTuple y0 ->
     (fun (a,b) -> Json.Encode.array [| Json.Encode.int a ; Json.Encode.int b  |]) y0

type suit =
  | Clubs
  | Diamonds
  | Hearts
  | Spades

let encodeSuit (x : suit) =
  match x with
  | Clubs ->
     Json.Encode.string "Clubs"
  | Diamonds ->
     Json.Encode.string "Diamonds"
  | Hearts ->
     Json.Encode.string "Hearts"
  | Spades ->
     Json.Encode.string "Spades"
  
type card =
  { suit  : suit
  ; value : int
  }

let encodeCard (x : card) =
  Json.Encode.object_
    [ ( "suit", encodeSuit x.suit )
    ; ( "value", Json.Encode.int x.value )
    ]

(*work around for the fact that ocaml does not support sum of product that has named accessors *)
  
type coo =
  | CooX of card
  | CooY of int 

let encodeCoo (x : coo) =
  match x with
  | CooX y0 ->
     (match (Js.Json.decodeObject (encodeCard y0)) with
      | Some dict ->
         Js.Dict.set dict "tag" (Js.Json.string "CooX");
         Js.Json.object_ dict;
      | None ->
         Json.Encode.object_ []
     )
  | CooY y0 ->
     Json.Encode.object_
       [ ( "tag", Json.Encode.string "CooY" )
       ; ( "contents", Json.Encode.int y0 )
       ]

type sumWithRecordA1 =
  { a1 : int    
  }

type sumWithRecordB2 =
  { b2 : string
  ; b3 : int
  }
   
type sumWithRecord =
  | A1 of sumWithRecordA1
  | B2 of sumWithRecordB2

let encodeA1 (x : sumWithRecordA1) =
  Json.Encode.object_
    [ ( "a1", Json.Encode.int x.a1 )
    ]

let encodeB2 (x : sumWithRecordB2) =
  Json.Encode.object_
    [ ( "b2", Json.Encode.string x.b2 )
    ; ( "b3", Json.Encode.int x.b3 )
    ]

let encodeSumWithRecord (x : sumWithRecord) =
  match x with
  | A1 y0 ->
     (match (Js.Json.decodeObject (encodeA1 y0)) with
      | Some dict ->
         Js.Dict.set dict "tag" (Js.Json.string "A1");
         Js.Json.object_ dict;
      | None ->
         Json.Encode.object_ []
     )
  | B2 y0 ->
     (match (Js.Json.decodeObject (encodeB2 y0)) with
      | Some dict ->
         Js.Dict.set dict "tag" (Js.Json.string "B2");
         Js.Json.object_ dict;
      | None ->
         Json.Encode.object_ []
     )