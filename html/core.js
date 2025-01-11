// html/core.js

function sleep() {}

// html/core.js

function SendNotification(data) {
    var notification = document.createElement('div');
    notification.className = 'notification redm animate__animated animate__fadeIn';

    var title = document.createElement('div');
    title.className = 'title';
    title.innerHTML = data.title;
    notification.appendChild(title);

    if (data.text) {
        var text = document.createElement('div');
        text.className = 'text';
        text.innerHTML = data.text;
        notification.appendChild(text);
    }

    let notifications = document.querySelector('.notifications');
    notifications.appendChild(notification);
    setTimeout(function () {
        notification.className = 'notification redm animate__animated animate__fadeOut';
        setTimeout(() => {
            notification.remove();
        }, 1000);
    }, data.duration || 5500);
}

window.addEventListener('message', function (event) {
    console.log("Received NUI message:", event.data);  // Debug log

    if (!event.data || typeof event.data !== 'object') {
        console.error("Invalid NUI message format:", event.data);  // Debug log
        return;
    }

    if (!event.data.type) {
        console.error("NUI message missing 'type':", event.data);  // Debug log
        return;
    }

    switch (event.data.type) {
        case 'SendNotification':
            console.log("Handling SendNotification event");  // Debug log
            SendNotification(event.data);
            break;
        case 'module_postoffice:SendNotification':
            console.log("Handling module_postoffice:SendNotification event with subject:", event.data.subject);  // Debug log
            SendNotification({
                title: "Nouveau Télégramme",
                text: `Vous avez reçu un nouveau télégramme`,
                position: "top_center",
                design: "redm",
                duration: 5500
            });
            break;
        default:
            console.error("Unknown event type:", event.data.type);  // Debug log
            break;
    }
});

document.onkeyup = function(data) {
    if (data.which == 27) {  // 27 = Echap
        jQuery.post(`https://${GetParentResourceName()}/escape`, JSON.stringify({}));
        return;
    }
};

jQuery(function () {
    function display(bool) {
        if (bool) {
            jQuery("#nui_content").show();
        } else {
            jQuery("#nui_content").hide();
        }
    }

    display(false)

    window.addEventListener('message', function (event) {
        var item = event.data;

        if (item.type === "ui") {
            if (item.status == true) {
                display(true)

                var postnum = item.postnum;
                var letters = item.letters;
                var sendprice = item.sendprice;
                var databaseName = item.databaseName;

                $("#yourpost").html("");
                $("#yourpost").html(postnum);

                $("#sendprice").html("");
                $("#sendprice").html(sendprice);

                Menus()

                $("#back").hide();
                $("#write_content").hide();
                $("#action_del").hide();
                $("#showing_block").hide();
                $('#deleteall').unbind('click').click(function () {
                    $.post(`https://${GetParentResourceName()}/delete_all`, JSON.stringify({
                        postnum: postnum
                    }));
                    Exit()
                    return
                })

                // Menu Fonction
                function Menus() {
                    $("#tab_name").html('POST OFFICE');
                    $("#menus").html(`
                        <div class="col-lg-6 my-2" id="letters_content">
                            <div class="cat_block d-flex flex-column rounded-1 p-3">
                                <div class="trader_case01 d-flex">
                                    <p class="my-auto text-light mx-auto tradename"><span>Receptions</span></p>
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-6 my-2" id="write">
                            <div class="cat_block d-flex flex-column rounded-1 p-3">
                                <div class="trader_case01 d-flex">
                                    <p class="my-auto text-light mx-auto tradename"><span>Ecrire</span></p>
                                </div>
                            </div>
                        </div>
                    `);
                }

                var inbox_open = false

                $('#back').unbind('click').click(function () {
                    $("#tab_name").html('POST OFFICE');
                    $("#write_content").hide();
                    $("#action_del").hide();
                    $("#letters_list").hide();
                    $("#menus").show();
                    $("#back").hide();
                    $("#showing_block").hide();
                })

                $('#write').unbind('click').click(function () {
                    write()
                    $("#tab_name").html('ÉCRIRE UN MESSAGE');
                    $("#write_content").show();
                    $("#showing_block").show();
                    $("#back").show();
                    $("#menus").hide();
                })

                $('#letters_content').unbind('click').click(function () {
                    OpenItems()
                    $("#action_del").show();
                    $("#letters_list").show();
                    $("#tab_name").html('LETTRES');
                    $("#back").show();
                    $("#menus").hide();
                    $("#showing_block").hide();
                })

                function write() {
                    $('#write_send').unbind('click').click(function () {
                        let recipiant = $("#recipiant").val()

                        var htmlContent = document.getElementById('editor')
                        letter = $('.ql-editor').html();  //htmlContent.innerHTML

                        let subject = $("#subject").val()
                        $.post(`https://${GetParentResourceName()}/send_letter`, JSON.stringify({
                            recipiant: recipiant,
                            letter: letter,
                            subject: subject,
                            sendprice: sendprice,
                            databaseName: databaseName
                        }));
                        Exit()
                    })
                }

                function OpenItems() {
                    if (inbox_open == false) {
                        var ims = 0;

                        for (single in letters) {
                            ims++;
                            if (letters[single].read_letter == 1) {
                                read = "read";
                            } else {
                                read = "new";
                            }
                            $("#letters_list").append(`
                                <div class="col-lg-12 my-2 letter_single `+ read + `" id="` + ims + `" data-id='` + letters[single].id + `' data-author='` + letters[single].rp_names + `'>
                                    <div class="d-flex w-100 letter_line" data-bs-toggle="offcanvas" data-bs-target="#read" aria-controls="read">
                                        <div class="me-2 my-auto"><img class="w-50" src="./design/folder_letters.png"></div>
                                        <div class="text-light ms-2 my-auto"><small>`+ letters[single].subject + `</small>
                                            <div><small>by ` + letters[single].rp_names + `</small></div>
                                        </div>
                                        <div class="text-light ms-auto my-auto">`+ letters[single].sender_postbox + `</div>
                                    </div>
                                    <div class="letter_hidden" style="display:none!important;">`+ letters[single].letter + `</div>
                                </div>
                            `);
                        }

                        inbox_open = true

                        $('.letter_single').unbind('click').click(function () {

                            var click = document.getElementById(this.id);
                            var id_letter = $(this).data('id');
                            var author = $(this).data('author');
                            var letter_open = $('#' + this.id + ' .letter_hidden').html();

                            click.classList.add("read");
                            $("#show_msg").html('');
                            $("#show_msg").html(letter_open);
                            $("#author").html('');
                            $("#author").html(author);
                            $("#delete").val()
                            $("#delete").val(id_letter)
                            $.post(`https://${GetParentResourceName()}/click_letter`, JSON.stringify({
                                id_letter: id_letter
                            }));
                        })

                        $('#delete').unbind('click').click(function () {
                            let supp = $("#delete").val()
                            $.post(`https://${GetParentResourceName()}/delete_letter`, JSON.stringify({
                                id_letter: supp
                            }));
                            Exit()
                            return
                        })

                    }
                }

            } else {
                display(false)
            }
        }
    })

    function exitMenu() {
        $("#tab_name").html('CRAFTING MENU');
        $("#action_del").hide();
        $("#letters_list").html('');
        $("#menus").show();
        $("#back").hide();
        $("#write_content").hide();
        $("#recipiant").val('');
        $("#subject").val('');
        $("#editor").val('');
        $("#showing_block").hide();
        $('.ql-editor').html('');
    }

    // Echap Key
    document.onkeyup = function (data) {
        if (data.which == 27) {
            exitMenu()
            jQuery.post(`https://${GetParentResourceName()}/exit`, JSON.stringify({}));
            return
        }
    };

    // Button for close
    jQuery("#quitter").click(function () {
        exitMenu()
        jQuery.post(`https://${GetParentResourceName()}/exit`, JSON.stringify({}));
        return
    })

    function Exit() {
        exitMenu()
        jQuery.post(`https://${GetParentResourceName()}/exit`, JSON.stringify({}));
    }

})