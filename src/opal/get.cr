module Opal
  extend self

  protected def get_image(r)
    ref = Name::Reference.parse_reference(r)
    V1::Remote.image(ref, V1::Remote.with_auth_from_keychain(Authn::DefaultKeychain.new))
  end

  protected def get_manifest(r)
    ref = Name::Reference.parse_reference(r)
    V1::Remote.get(ref, V1::Remote.with_auth_from_keychain(Authn::DefaultKeychain.new))
  end
end
