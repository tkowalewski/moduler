require "tailwindcss-rails"

namespace :moduler do
  namespace :tailwindcss do
    desc "Build Tailwind CSS for Moduler Engine"
    task :build do
      input_path = "app/assets/stylesheets/moduler/tailwind.css"
      output_path = "app/assets/builds/moduler/tailwind.css"

      FileUtils.mkdir_p(Moduler::Engine.root.join("app/assets/builds/moduler"))

      command = [
        Tailwindcss::Ruby.executable,
        "--input", input_path,
        "--output", output_path,
        "--minify"
      ]

      Dir.chdir(Moduler::Engine.root) do
        system(*command, exception: true)
      end
    end

    desc "Watch and build Tailwind CSS for Moduler Engine"
    task :watch do
      input_path = "app/assets/stylesheets/moduler/tailwind.css"
      output_path = "app/assets/builds/moduler/tailwind.css"

      FileUtils.mkdir_p(Moduler::Engine.root.join("app/assets/builds/moduler"))

      command = [
        Tailwindcss::Ruby.executable,
        "--input", input_path,
        "--output", output_path,
        "--watch",
        "--minify"
      ]

      Dir.chdir(Moduler::Engine.root) do
        system(*command, exception: true)
      end
    end
  end
end
