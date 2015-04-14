gem_name = File.basename(Dir[File.expand_path("../*.gemspec", __FILE__)].first)[0..-9]

guard(:minitest, :all_after_pass => false, :all_on_start => false) do
  watch(%r{^lib/#{gem_name}/(.+)\.rb$}) { |m| "test/unit/#{m[1]}_test.rb" }
  watch(%r{^test/.+_test\.rb$})
  watch(%r{^(?:test/test_helper(.*)|lib/#{gem_name})\.rb$}) { "test" }
end
