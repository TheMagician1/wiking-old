// More
jsToolBar.prototype.elements.more = {
    type: 'button',
    title: 'More',
    fn: {
        wiki: function() { window.open(this.help_link, '', 'resizable=yes, location=no, width=300, height=640, menubar=no, status=no, scrollbars=yes') }
    }
}
