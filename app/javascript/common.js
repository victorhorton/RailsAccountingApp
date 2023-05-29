export function parseDate(date) {
  if (!date) {
    return null;
  }
  const splitDate = date.split('-');
  const splitMonth = splitDate[1];
  const splitDay = splitDate[2];
  const splitYear = splitDate[0].substring(2, 4);
  return `${splitMonth}-${splitDay}-${splitYear}`;
}

export function parseAmount(amount) {
  if (!amount) {
    return null;
  }
  const splitAmount = amount.toString().split('.');
  const wholeNumber = parseFloat(splitAmount[0]).toLocaleString("en-US");
  let decimalNumber = splitAmount[1];
  if (decimalNumber == undefined || decimalNumber.length == 0) {
    decimalNumber = '00';
  } else if (decimalNumber.length == 1) {
    decimalNumber = `${decimalNumber}0`;
  }

  return `${wholeNumber}.${decimalNumber}`;
}

export function formatDate(date) {
  if (!date) {
    return null;
  }
  const splitDate = date.split('-');
  return `20${splitDate[2]}-${splitDate[0]}-${splitDate[1]}`;
}

export function sumTotals(amounts) {
  return amounts.reduce( ( a, b ) => {
    if (a === '') {
      a = 0;
    } else {
      a = `${a}`.replace(',', '');
    }
    if (b === '') {
      b = 0;
    } else {
      b = `${b}`.replace(',', '');
    }
    return parseFloat(a) + parseFloat(b);
  }, 0 );
}
