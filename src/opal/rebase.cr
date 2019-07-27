module Opal
  class CLI < Cli::Supercommand
    command "rebase"

    class Rebase < Cli::Command
      command_name "rebase"

      class Options
        arg "original", desc: "Original image to rebase", required: true
        arg "old-base", desc: "Old base image to remove", required: true
        arg "new-base", desc: "New base image to insert", required: true
        arg "rebased", desc: "Tag to apply to rebased image", required: true
        help
      end

      class Help
        header "Rebase an image onto a new base image"
        caption "Rebase an image onto a new base image"
      end

      def run
        orig_img = Opal.get_image(args.original)
        old_base_img = Opal.get_image(args.old_base)
        new_base_img = Opal.get_image(args.new_base)

        rebased_tag = Name::Tag.new args.rebased
        rebased_img = V1::Mutate.rebase(orig_img, old_base_img, new_base_img)

        dig = rebased_img.digest

        V1::Remote.write(rebased_tag, rebased_img, V1::Remote.with_auth_from_keychain(Authn::DefaultKeychain.new))

        puts dig.to_s
      rescue ex
        Logger.error "Error occurred: \n#{ex.message}"
        exit! code: 2
      end
    end
  end
end
