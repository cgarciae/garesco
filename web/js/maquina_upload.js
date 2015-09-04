var fields = ["eti", "pais", "venta", "precio", "aNo", "linkVideo",
    "enEmail", "descripcion", "modelo"];

var form = document.getElementById('data-form');


form.onsubmit = function(event) {
    event.preventDefault();

    console.log(form);

    var files = form["archivosImagenes"].files;

    // Create a new FormData object.
    var formData = new FormData();

    console.log(files);
    for (var i = 0; i < files.length; i++) {
        var file = files[i];

        // Check the file type.
        if (!file.type.match('image.*')) {
            continue;
        }
        console.log(file);
        // Add the file to the request.
        formData.append('file' + i, file);
    }

    for (i = 0; i < fields.length; i++) {
        formData.append(fields[i], form[fields[i]].value);
    }

    // Set up the request.
    var url = window.location.pathname;
    var xhr = new XMLHttpRequest();

    xhr.open('POST', url, true);

    xhr.onload = function () {
        if (xhr.status === 200) {
            window.location.reload();
        } else {
            alert('An error occurred!');
        }
    };

    //xhr.send(formData);
}