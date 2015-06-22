import 'dart:html';

FormElement dataForm;
LabelElement dataLabel;
AnchorElement deleteLabel;
ElementList<AnchorElement> botonesEliminar;

void main () {
  print("START2");

  deleteLabel = querySelector('#delete-label');
  botonesEliminar = querySelectorAll('.eliminar-foto');


  deleteLabel.onClick.listen((e) {
    print("DELTE");
    e.preventDefault();
    e.stopImmediatePropagation();
    () async {
      HttpRequest req = await HttpRequest.request(
          deleteLabel.href,
          method: "DELETE"
      );
      window.location.replace(req.responseText);
    }();
  });
  for (var element in botonesEliminar) {
    element.onClick.listen((e) {
      e.preventDefault();
      e.stopImmediatePropagation();

      () async {
        await HttpRequest.request(element.href, method: "DELETE");
        window.location.reload();
      }();
    });
  }
}