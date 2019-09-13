using Gtk;
using Granite;

public class Tootle.Views.Profile : Views.Timeline {

    public API.Account account { get; construct set; } 

    protected Label posts_label;
    protected Label following_label;
    protected Label followers_label;

    construct {
        var builder = new Builder.from_resource (@"$(Build.RESOURCES)ui/views/profile_header.ui");
		view.pack_start (builder.get_object ("grid") as Grid, false, false, 0);
		
		var avatar = builder.get_object ("avatar") as Widgets.Avatar;
		avatar.url = account.avatar;
		
		var name = builder.get_object ("name") as Widgets.RichLabel;
		account.bind_property ("display-name", name, "label", BindingFlags.SYNC_CREATE, (b, src, ref target) => {
			var label = (string) src;
			target.set_string (@"<span size='x-large' weight='bold'>$label</span>");
			return true;
		});
		
		var handle = builder.get_object ("handle") as Widgets.RichLabel;
		account.bind_property ("acct", handle, "label", BindingFlags.SYNC_CREATE, (b, src, ref target) => {
			target.set_string ("@" + (string) src);
			return true;
		});
		
		var note = builder.get_object ("note") as Widgets.RichLabel;
		account.bind_property ("note", note, "label", BindingFlags.SYNC_CREATE, (b, src, ref target) => {
			target.set_string (Html.simplify ((string) src));
			return true;
		});
		
		posts_label = builder.get_object ("posts_label") as Label;
		account.bind_property ("posts_count", posts_label, "label", BindingFlags.SYNC_CREATE, (b, src, ref target) => {
		    var val = (int64) src;
			target.set_string (_("%s Posts").printf (@"<b>$val</b>"));
			return true;
		});
		following_label = builder.get_object ("following_label") as Label;
		account.bind_property ("following_count", following_label, "label", BindingFlags.SYNC_CREATE, (b, src, ref target) => {
		    var val = (int64) src;
			target.set_string (_("%s Follows").printf (@"<b>$val</b>"));
			return true;
		});
		followers_label = builder.get_object ("followers_label") as Label;
		account.bind_property ("followers_count", followers_label, "label", BindingFlags.SYNC_CREATE, (b, src, ref target) => {
		    var val = (int64) src;
			target.set_string (_("%s Followers").printf (@"<b>$val</b>"));
			return true;
		});
    }

    public Profile (API.Account acc) {
        Object (account: acc, state: "content");
        //account.updated.connect (rebind);

        account.get_relationship ();
        request ();
    }

    public override bool is_status_owned (API.Status status) {
        return status.is_owned ();
    }

    public override string get_url () {
        if (page_next != null)
            return page_next;

        var url = "%s/api/v1/accounts/%lld/statuses?limit=%i".printf (accounts.active.instance, account.id, this.limit);
        return url;
    }

    public override void request () {
        if (account != null)
            base.request ();
    }

    public static void open_from_id (int64 id){
        var url = "%s/api/v1/accounts/%lld".printf (accounts.active.instance, id);
        var msg = new Soup.Message ("GET", url);
        msg.priority = Soup.MessagePriority.HIGH;
        network.queue (msg, (sess, mess) => {
            var root = network.parse (mess);
            var acc = API.Account.parse (root);
            window.open_view (new Views.Profile (acc));
        }, (status, reason) => {
            network.on_error (status, reason);
        });
    }

}
