jQuery('tbody#client_body').html('<%= escape_javascript render("clients") %>');
jQuery('.paginator').html('<%= escape_javascript(paginate(@clients, :remote => true).to_s) %>' +
    '<div class="paging_info"><%= page_entries_info @clients %></div>');