module Opal
  class CLI < Cli::Supercommand
    command "cp", aliased: "copy"

    class Copy < Cli::Command
      command_name "copy"

      class Options
        arg "src", desc: "Source Image", required: true
        arg "dst", desc: "Destination Image", required: true
        help
      end

      class Help
        header "Efficiently copy a remote image from src to dst"
        caption "Efficiently copy a remote image from src to dst"
      end

      def run
        src_ref = Name::Reference.parse_reference args.src
        Logger.info "Pulling #{src_ref.to_s}"
        desc = V1::Remote.get src_ref, V1::Remote.with_auth_from_keychain(Authn::DefaultKeychain.new)
        dst_ref = Name::Reference.parse_reference args.dst
        Logger.info "Pushing #{dst_ref.to_s}"

        case desc.media_type
        when V1::Types::OCIIMAGEINDEX, V1::Types::DOCKERMANIFESTLIST
          # Handle indexes separately
          copy_index desc, dst_ref
        else
          # Assume anything else is an image, since some registries don't set media-type properly
          copy_image desc, dst_ref
        end
      rescue ex
        Logger.error "Error occurred: \n#{ex.message}"
        exit! code: 2
      end

      private def copy_image(desc, dst_ref)
        img = desc.image
        V1::Remote.write(dst_ref, img, V1::Remote.with_auth_from_keychain(Authn::DefaultKeychain.new))
      end

      private def copy_index(desc, dst_ref)
        idx = desc.image_index
        V1::Remote.write_index(dst_ref, idx, V1::Remote.with_auth_from_keychain(Authn::DefaultKeychain.new))
      end
    end
  end
end
