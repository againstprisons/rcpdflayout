var search_data = {"index":{"searchIndex":["rcpdflayout","document","object","image","page","textbox","textsegment","textmarkup","commonmarkerrenderer","utils","calculate_child_size()","composite()","create_image()","deferred?()","from_markup_segment()","image_write()","mogrify()","new()","new()","new()","new()","new()","new()","parse_from_markdown()","parse_segments()","render_final()","render_final()","render_final()","render_final()","render_final()","render_text()","write()","readme"],"longSearchIndex":["rcpdflayout","rcpdflayout::document","rcpdflayout::object","rcpdflayout::object::image","rcpdflayout::object::page","rcpdflayout::object::textbox","rcpdflayout::object::textsegment","rcpdflayout::textmarkup","rcpdflayout::textmarkup::commonmarkerrenderer","rcpdflayout::utils","rcpdflayout::object#calculate_child_size()","rcpdflayout::object#composite()","rcpdflayout::object::create_image()","rcpdflayout::object#deferred?()","rcpdflayout::object::textsegment::from_markup_segment()","rcpdflayout::utils#image_write()","rcpdflayout::object#mogrify()","rcpdflayout::document::new()","rcpdflayout::object::new()","rcpdflayout::object::image::new()","rcpdflayout::object::page::new()","rcpdflayout::object::textbox::new()","rcpdflayout::object::textsegment::new()","rcpdflayout::textmarkup#parse_from_markdown()","rcpdflayout::textmarkup#parse_segments()","rcpdflayout::object#render_final()","rcpdflayout::object::image#render_final()","rcpdflayout::object::page#render_final()","rcpdflayout::object::textbox#render_final()","rcpdflayout::object::textsegment#render_final()","rcpdflayout::object::textbox::render_text()","rcpdflayout::document#write()",""],"info":[["RcPdfLayout","","RcPdfLayout.html","","<p>Simple PDF layout &amp; generation library\n"],["RcPdfLayout::Document","","RcPdfLayout/Document.html","","<p>Representation of a PDF document consisting of one or more pages\n"],["RcPdfLayout::Object","","RcPdfLayout/Object.html","","<p>The base object class\n<p>The base object class\n<p>The base object class\n"],["RcPdfLayout::Object::Image","","RcPdfLayout/Object/Image.html","","<p>An image object\n"],["RcPdfLayout::Object::Page","","RcPdfLayout/Object/Page.html","","<p>A page object, used for constructing documents\n"],["RcPdfLayout::Object::TextBox","","RcPdfLayout/Object/TextBox.html","","<p>A bounded text container.\n<p><code>TextBox</code> will automatically perform line wrapping of text, should the lines of …\n"],["RcPdfLayout::Object::TextSegment","","RcPdfLayout/Object/TextSegment.html","","<p>A segment of text\n"],["RcPdfLayout::TextMarkup","","RcPdfLayout/TextMarkup.html","","<p>Text markup parser.\n<p>The text markup used by RcPdfLayout is relatively simple. Markup tags are formatted …\n"],["RcPdfLayout::TextMarkup::CommonMarkerRenderer","","RcPdfLayout/TextMarkup/CommonMarkerRenderer.html","","<p>A CommonMarker renderer that outputs RcPdfLayout markup.\n"],["RcPdfLayout::Utils","","RcPdfLayout/Utils.html","","<p>Miscellaneous utility functions\n"],["calculate_child_size","RcPdfLayout::Object","RcPdfLayout/Object.html#method-i-calculate_child_size","(child, ppi = nil)",""],["composite","RcPdfLayout::Object","RcPdfLayout/Object.html#method-i-composite","(image, &block)","<p>Composite a second image onto the object&#39;s image, returning <code>self</code>.\n<p>@param image [MiniMagick::Image] …\n"],["create_image","RcPdfLayout::Object","RcPdfLayout/Object.html#method-c-create_image","(opts = {}, &block)","<p>Create a blank image object.\n<p>The returned image is fully transparent, and is in the PNG format.\n<p>@yield …\n"],["deferred?","RcPdfLayout::Object","RcPdfLayout/Object.html#method-i-deferred-3F","()","<p>Returns whether image operations are deferred until render time\n<p>@return [true, false]\n"],["from_markup_segment","RcPdfLayout::Object::TextSegment","RcPdfLayout/Object/TextSegment.html#method-c-from_markup_segment","(position_mm, segment, opts = {})","<p>Create a text segment object from a markup segment.\n<p>@param position_mm [Array&lt;Float&gt;]\n\n<pre class=\"ruby\"><span class=\"ruby-constant\">The</span> <span class=\"ruby-identifier\">position</span> <span class=\"ruby-operator\">...</span>\n</pre>\n"],["image_write","RcPdfLayout::Utils","RcPdfLayout/Utils.html#method-i-image_write","(image, filename, opts = {})","<p>Write a potentially-optimized version of a <code>MiniMagick::Image</code> to the given output file.\n<p>This attempts to …\n"],["mogrify","RcPdfLayout::Object","RcPdfLayout/Object.html#method-i-mogrify","(&block)","<p>Perform operations on the object&#39;s image in place, returning <code>self</code>.\n<p>@yield [MiniMagick::Tool::Mogrify] …\n"],["new","RcPdfLayout::Document","RcPdfLayout/Document.html#method-c-new","()","<p>Create a new empty document.\n"],["new","RcPdfLayout::Object","RcPdfLayout/Object.html#method-c-new","(position_mm, size_mm, ppi, opts = {})","<p>@param position_mm [Array&lt;Float&gt;] The position of the object on the page,\n\n<pre>as an array of +x, y+ ...</pre>\n"],["new","RcPdfLayout::Object::Image","RcPdfLayout/Object/Image.html#method-c-new","(position_mm, size_mm, ppi, opts = {})","<p>Create a new image object. @param position_mm [Array&lt;Float&gt;] The position of the object on the …\n"],["new","RcPdfLayout::Object::Page","RcPdfLayout/Object/Page.html#method-c-new","(size_mm, ppi, opts = {})","<p>Create a new page object.\n<p>@param size_mm [Array&lt;Float&gt;] The size of the page, as an array of\n\n<pre>+width, ...</pre>\n"],["new","RcPdfLayout::Object::TextBox","RcPdfLayout/Object/TextBox.html#method-c-new","(position_mm, size_mm, ppi, opts = {})","<p>Create a new text box object. @param position_mm [Array&lt;Float&gt;] The position of the object on the …\n"],["new","RcPdfLayout::Object::TextSegment","RcPdfLayout/Object/TextSegment.html#method-c-new","(position_mm, text, opts = {})","<p>Create a new text segment\n"],["parse_from_markdown","RcPdfLayout::TextMarkup","RcPdfLayout/TextMarkup.html#method-i-parse_from_markdown","(text)","<p>Parse a Markdown document into RcPdfLayout text markup segments\n"],["parse_segments","RcPdfLayout::TextMarkup","RcPdfLayout/TextMarkup.html#method-i-parse_segments","(text)","<p>Parse a string of marked-up text into it&#39;s individual segments.\n<p>A “text segment” is defined …\n"],["render_final","RcPdfLayout::Object","RcPdfLayout/Object.html#method-i-render_final","(opts = {})","<p>Return the final rendered version of this object as an image.\n<p>The base Object class implements this method …\n"],["render_final","RcPdfLayout::Object::Image","RcPdfLayout/Object/Image.html#method-i-render_final","(opts = {})","<p>Return the final rendered version of this object as an image.\n<p>@param opts [Hash] Render options @return …\n"],["render_final","RcPdfLayout::Object::Page","RcPdfLayout/Object/Page.html#method-i-render_final","(opts = {})","<p>Return the final rendered version of this page as an image.\n<p>@param opts [Hash] Render options @return …\n"],["render_final","RcPdfLayout::Object::TextBox","RcPdfLayout/Object/TextBox.html#method-i-render_final","(opts = {})","<p>Return this text box as a rendered image\n<p>@param opts [Hash] Render options @return [MiniMagick::Image] …\n"],["render_final","RcPdfLayout::Object::TextSegment","RcPdfLayout/Object/TextSegment.html#method-i-render_final","(opts = {})","<p>Return the rendered text segment\n<p>@param opts [Hash] Render options @return [MiniMagick::Image] Rendered …\n"],["render_text","RcPdfLayout::Object::TextBox","RcPdfLayout/Object/TextBox.html#method-c-render_text","(segments, width_mm, opts = {})","<p>Renders the given <code>segments</code> (the output of a parsing function within <code>RcPdfLayout::TextMarkup</code>) into an …\n"],["write","RcPdfLayout::Document","RcPdfLayout/Document.html#method-i-write","(filename, opts = {})","<p>Write this document to a named PDF file.\n<p>@param opts [Hash] Render options @param opts :page_opts [Hash] …\n"],["README","","README_md.html","","<p>rcpdflayout\n<p>The PDF layout &amp; generation library used by re:connect.\n<p>Installation\n"]]}}