module Opal
  class CLI < Cli::Supercommand
    command "pull"

    class Pull < Cli::Command
      command_name "pull"

      class Options
        arg "src", desc: "Source Image", required: true
        arg "dst", desc: "Destination Image", required: true
        string ["-c", "--cache-path"], desc: "Path to cache image layers", default: ""
        help
      end

      class Help
        header "Pull a remote image by reference and store its contents in a tarball"
        caption "Pull a remote image by reference and store its contents in a tarball"
      end

      def run
        ref = Name::Reference.parse_reference args.src
        Logger.info "Pulling #{ref.to_s}"
        img = V1::Remote.image ref, V1::Remote.with_auth_from_keychain(Authn::DefaultKeychain.new)
        img = V1::Cache.image(img, V1::Cache::FileSystemCache.new(args.cache_path)) unless args.cache_path.blank?
        # write_to_file wants a tag to write to the tarball, but we might have
        # been given a digest.
        # If the original ref was a tag, use that. Otherwise, if it was a
        # digest, tag the image with :i-was-a-digest instead.
        if ref.is_a?(Name::Tag)
          tag = ref.as(Name::Tag)
        else
          if ref.is_a?(Name::Digest)
            d = ref.as(Name::Digest)
            s = "#{d.as_repository.name}:i-was-a-digest"
            tag = Name::Tag.new s
          else
            Logger.error "ref wasn't a Tag or Digest"
            exit! code: 2
          end
        end
        V1::Tarball.write_to_file(args.dst, tag, img)
      rescue ex
        Logger.error "Error occurred: \n#{ex.message}"
        exit! code: 2
      end
    end
  end
end
