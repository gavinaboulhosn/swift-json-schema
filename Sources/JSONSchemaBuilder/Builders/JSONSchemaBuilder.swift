import JSONSchema

/// A result builder type to build JSON schemas.
///
/// Here's an example of how you might use this builder to create a JSON schema for a product:
/// ```swift
/// JSONObject {
///   JSONProperty(key: "productId") {
///     JSONInteger().description("The unique identifier for a product")
///   }
///   JSONProperty(key: "productName")
///     JSONString().description("Name of the product")
///   }
/// }
/// .description("A product from Acme's catalog")
/// ```
@resultBuilder public enum JSONSchemaBuilder {
  public static func buildBlock<Component: JSONSchemaComponent>(_ component: Component) -> Component
  { component }

  public static func buildBlock(_ expression: Bool) -> JSONBooleanSchema {
    .init(value: expression)
  }

  // MARK: Advanced builers

  public static func buildOptional<Component: JSONSchemaComponent>(
    _ component: Component?
  ) -> JSONComponents.OptionalNoType<Component> { .init(wrapped: component) }

  public static func buildEither<TrueComponent, FalseComponent>(
    first component: TrueComponent
  ) -> JSONComponents.Conditional<TrueComponent, FalseComponent> { .first(component) }

  public static func buildEither<TrueComponent, FalseComponent>(
    second component: FalseComponent
  ) -> JSONComponents.Conditional<TrueComponent, FalseComponent> { .second(component) }
}

@resultBuilder public enum JSONSchemaCollectionBuilder<Output> {
  public static func buildPartialBlock<Component: JSONSchemaComponent>(
    first component: Component
  ) -> [JSONComponents.AnyComponent<Output>] where Component.Output == Output {
    [component.eraseToAnyComponent()]
  }

  public static func buildPartialBlock<Component: JSONSchemaComponent>(
    accumulated: [JSONComponents.AnyComponent<Output>],
    next component: Component
  ) -> [JSONComponents.AnyComponent<Output>] where Component.Output == Output {
    accumulated + [component.eraseToAnyComponent()]
  }
}

extension JSONSchemaCollectionBuilder where Output == JSONValue {
  public static func buildPartialBlock<Component: JSONSchemaComponent>(
    first component: Component
  ) -> [JSONComponents.AnyComponent<JSONValue>] {
    [JSONComponents.Passthrough(wrapped: component).eraseToAnyComponent()]
  }

  public static func buildPartialBlock<Component: JSONSchemaComponent>(
    accumulated: [JSONComponents.AnyComponent<JSONValue>],
    next component: Component
  ) -> [JSONComponents.AnyComponent<JSONValue>] {
    accumulated + [JSONComponents.Passthrough(wrapped: component).eraseToAnyComponent()]
  }
}
