let userIdToInt = (userId: SharedTypes.userId) =>
  switch (userId) {
  | UserId(Key(d)) => d
  };

module MakeServerFetch = (Config: ServerFetchConfig.Config) => {
  type serverRoute =
    | TodoR(SharedTypes.userId)
    | TodosR(SharedTypes.userId)
    | UserR;
  let toRoute = (route: serverRoute) : string => {
    let base = Config.baseUrl;
    let urlPath =
      switch (route) {
      | TodoR(userId) => Printf.sprintf("/todos/%d", userIdToInt(userId))
      | TodosR(userId) => Printf.sprintf("/todo/%d", userIdToInt(userId))
      | UserR => "user"
      };
    base ++ urlPath;
  };

  let postUserTodo = (userId, todo) => {
    let url = toRoute(TodoR(userId));
    let headers =
      Fetch.HeadersInit.makeWithArray([|("Accept", "application/json")|]);
    let body =
      SharedTypes.encodeTodo(todo) |> Js.Json.stringify |> Fetch.BodyInit.make;
    Js.Promise.(
      Fetch.fetchWithInit(
        url,
        Fetch.RequestInit.make(
          ~method_=Post,
          ~headers,
          ~credentials=Include,
          ~body,
          (),
        ),
      )
      |> then_(Fetch.Response.json)
      |> then_(json =>
           SharedTypes.(decodeEntity(decodeTodoId, decodeTodo, json))
           |> resolve
         )
    );
  };
  let getUserTodos = userId => {
    let url = toRoute(TodosR(userId));
    let headers =
      Fetch.HeadersInit.makeWithArray([|("Accept", "application/json")|]);
    Js.Promise.(
      Fetch.fetchWithInit(
        url,
        Fetch.RequestInit.make(
          ~method_=Get,
          ~headers,
          ~credentials=Include,
          (),
        ),
      )
      |> then_(Fetch.Response.json)
      |> then_(json =>
           SharedTypes.(
             Aeson.Decode.array(decodeEntity(decodeTodoId, decodeTodo), json)
           )
           |> resolve
         )
    );
  };

  let postUser = user => {
    let url = toRoute(UserR);
    let headers =
      Fetch.HeadersInit.makeWithArray([|("Accept", "application/json")|]);
    let body =
      SharedTypes.encodeUser(user) |> Js.Json.stringify |> Fetch.BodyInit.make;
    Js.Promise.(
      Fetch.fetchWithInit(
        url,
        Fetch.RequestInit.make(
          ~method_=Post,
          ~headers,
          ~credentials=Include,
          ~body,
          (),
        ),
      )
      |> then_(Fetch.Response.json)
      |> then_(json =>
           SharedTypes.(decodeEntity(decodeUserId, decodeUser, json))
           |> resolve
         )
    );
  };
};