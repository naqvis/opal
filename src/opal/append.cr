module Opal
  class CLI < Cli::Supercommand
    command "append"

    class Append < Cli::Command
      command_name "append"

      class Options
        string ["-b", "--base"], desc: "Name of base image to append to", required: true
        string ["-t", "--new_tag"], desc: "Tag to apply to resulting image", required: true
        string ["-f", "--new_layer"], desc: "Path to tarball to append to image", required: true
        string ["-o", "--output"], desc: "Path to new tarball of resulting image", default: ""
        help
      end

      class Help
        header "Append contents of a tarball to a remote image"
        caption "Append contents of a tarball to a remote image"
      end

      def run
        append(args.base, args.new_tag, args.new_layer, args.output)
      end

      private def append(src, dst, tar, output)
        src_ref = Name::Reference.parse_reference(src)
        dst_tag = Name::Tag.new dst
        layer = V1::Tarball::Layer.from_file(tar)
        src_img = V1::Remote.image(src_ref, V1::Remote.with_auth_from_keychain(Authn::DefaultKeychain.new))
        image = V1::Mutate.append_layers src_img, [layer]
        unless output.blank?
          V1::Tarball.write_to_file output, dst_tag, image
        end
        V1::Remote.write dst_tag, image, V1::Remote.with_auth_from_keychain(Authn::DefaultKeychain.new)
        Logger.info "Image written to #{dst_tag.to_s} successfully"
      rescue ex
        Logger.error "Error occurred: \n#{ex.message}"
        exit! code: 2
      end
    end
  end
end
