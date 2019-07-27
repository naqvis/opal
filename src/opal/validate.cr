module Opal
  class CLI < Cli::Supercommand
    command "validate"

    class Validate < Cli::Command
      command_name "validate"

      class Options
        arg "image", desc: "Image to validate", required: true
        arg "type", any_of: %w(Tarball Remote), required: true
        help
      end

      class Help
        header "Validate that an image is well-formed"
        caption "Validate that an image is well-formed"
      end

      def run
        V1::Validator.validate get_image(args.image, args.type)
        puts "PASS: #{args.type}"
      rescue ex
        Logger.error "Error occurred: \n#{ex.message}"
        exit! code: 2
      end

      private def get_image(path : String, t : String)
        case t
        when "Tarball"
          V1::Tarball.image_from_path(path, nil)
        when "Remote"
          ref = Name::Reference.parse_reference path
          V1::Remote.image(ref, V1::Remote.with_auth_from_keychain(Authn::DefaultKeychain.new))
        else
          raise "Unknown Type: #{t}"
        end
      end
    end
  end
end
