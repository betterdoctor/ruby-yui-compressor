require "test/unit"
require "yui/compressor"

module YUI
  class CompressorTest < Test::Unit::TestCase
    FIXTURE_CSS = <<-END_CSS
      div.warning {
        display: none;
      }
      
      div.error {
        background: red;
        color: white;
      }
    END_CSS

    FIXTURE_JS = <<-END_JS
      // here's a comment
      var Foo = { "a": 1 };
      Foo["bar"] = (function(baz) {
        /* here's a
           multiline comment */
        if (false) {
          doSomething();
        } else {
          for (var index = 0; index < baz.length; index++) {
            doSomething(baz[index]);
          }
        }
      })("hello");
    END_JS
    
    def test_css_should_be_compressed_when_type_is_css
      @compressor = YUI::Compressor.new(:type => :css)
      assert_equal "div.warning{display:none;}div.error{background:red;color:white;}", @compressor.compress(FIXTURE_CSS)
    end
    
    def test_js_should_be_compressed_when_type_is_js
      @compressor = YUI::Compressor.new(:type => :js)
      assert_equal "var Foo={a:1};Foo.bar=(function(baz){if(false){doSomething()}else{for(var index=0;index<baz.length;index++){doSomething(baz[index])}}})(\"hello\");", @compressor.compress(FIXTURE_JS)
    end
    
    def test_js_should_be_the_default_compression_type
      @compressor = YUI::Compressor.new
      assert_equal "var Foo={a:1};Foo.bar=(function(baz){if(false){doSomething()}else{for(var index=0;index<baz.length;index++){doSomething(baz[index])}}})(\"hello\");", @compressor.compress(FIXTURE_JS)
    end
    
    def test_compress_should_raise_when_an_unknown_option_is_specified
      assert_raises YUI::Compressor::NoOptionError do
        @compressor = YUI::Compressor.new(:foo => "bar")
        @compressor.compress(FIXTURE_JS)
      end
    end

    def test_compress_should_accept_an_io_argument
      @compressor = YUI::Compressor.new(:type => :css)
      assert_equal "div.warning{display:none;}div.error{background:red;color:white;}", @compressor.compress(StringIO.new(FIXTURE_CSS))
    end
    
    def test_compress_should_accept_a_block_and_yield_an_io
      @compressor = YUI::Compressor.new(:type => :css)
      @compressor.compress(FIXTURE_CSS) do |stream|
        assert_kind_of IO, stream
        assert_equal "div.warning{display:none;}div.error{background:red;color:white;}", stream.read
      end
    end
    
    def test_line_break_option_should_insert_line_breaks_in_css
      @compressor = YUI::Compressor.new(:line_break => 0, :type => :css)
      assert_equal "div.warning{display:none;}\ndiv.error{background:red;color:white;}", @compressor.compress(FIXTURE_CSS)
    end
    
    def test_line_break_option_should_insert_line_breaks_in_js
      @compressor = YUI::Compressor.new(:line_break => 0)
      assert_equal "var Foo={a:1};\nFoo.bar=(function(baz){if(false){doSomething()\n}else{for(var index=0;\nindex<baz.length;\nindex++){doSomething(baz[index])\n}}})(\"hello\");", @compressor.compress(FIXTURE_JS)
    end
    
    def test_munge_option_should_munge_local_variable_names
      @compressor = YUI::Compressor.new(:munge => true)
      assert_equal "var Foo={a:1};Foo.bar=(function(b){if(false){doSomething()}else{for(var a=0;a<b.length;a++){doSomething(b[a])}}})(\"hello\");", @compressor.compress(FIXTURE_JS)
    end
    
    def test_optimize_option_should_not_modify_property_accesses_or_object_literal_keys_when_false
      @compressor = YUI::Compressor.new(:optimize => false)
      assert_equal "var Foo={\"a\":1};Foo[\"bar\"]=(function(baz){if(false){doSomething()}else{for(var index=0;index<baz.length;index++){doSomething(baz[index])}}})(\"hello\");", @compressor.compress(FIXTURE_JS)
    end

    def test_preserve_semicolons_option_should_preserve_semicolons
      @compressor = YUI::Compressor.new(:preserve_semicolons => true)
      assert_equal "var Foo={a:1};Foo.bar=(function(baz){if(false){doSomething();}else{for(var index=0;index<baz.length;index++){doSomething(baz[index]);}}})(\"hello\");", @compressor.compress(FIXTURE_JS)
    end
  end
end
