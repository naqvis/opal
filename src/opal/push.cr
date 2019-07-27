module Opal
  class CLI < Cli::Supercommand
    command "push"

    class Push < Cli::Command
      command_name "push"

      class Options
        arg "src", desc: "Source Image", required: true
        arg "dst", desc: "Destination", required: true
        help
      end

      class Help
        header "Push image contents as a tarball to a remote registry"
        caption "Push image contents as a tarball to a remote registry"
      end

      def run
        t = Name::Tag.new args.dst
        Logger.info "Pushing #{t.to_s}"
        i = V1::Tarball.image_from_path args.src, nil
        V1::Remote.write t, i, V1::Remote.with_auth_from_keychain(Authn::DefaultKeychain.new)
      rescue ex
        Logger.error "Error occurred: \n#{ex.message}"
        exit! code: 2
      end
    end
  end
end
