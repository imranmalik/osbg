jQuery('tbody#tax_body').html('<%= escape_javascript render("taxes") %>');
jQuery('.paginator').html('<%= escape_javascript(paginate(@taxes, :remote => true).to_s) %>' +
    '<div class="paging_info"><%= page_entries_info @taxes %></div>');