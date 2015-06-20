import 'dart:html';

FormElement dataForm;
LabelElement dataLabel;
AnchorElement deleteLabel;
ElementList<AnchorElement> botonesEliminar;

void main () {
  print("START2");
  dataForm = querySelector('#data-form');
  dataLabel = querySelector('#data-label');
  deleteLabel = querySelector('#delete-label');
  botonesEliminar = querySelectorAll('.eliminar-foto');

  dataLabel.onClick.listen((e) async {
    HttpRequest req = await HttpRequest.request(
      dataForm.action,
      method: dataForm.method,
      sendData: new FormData(dataForm)
    );
    window.location.replace(req.responseText);
  });
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